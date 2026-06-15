// @ts-nocheck -- this file runs in the Supabase Deno edge runtime, which
// provides the `Deno` global and resolves https:// imports natively. A
// plain VS Code TypeScript server doesn't know about either, so it reports
// false-positive errors here unless the Deno extension is installed.
//
// Edge Function: stripe-payment
//
// Handles the two steps of a real (test-mode) card payment for a student's
// outstanding fees:
//
//   mode "create"  -> server computes the amount owed from `student_fees`
//                      (never trusts the client) and creates a Stripe
//                      PaymentIntent, returning its client secret.
//
//   mode "confirm" -> after the Flutter app confirms the PaymentIntent with
//                      Stripe, re-checks its status directly with Stripe and,
//                      only if "succeeded", marks the student's unpaid fees
//                      as paid using the service-role key (bypasses RLS).
//
// Required secrets (set in Supabase Dashboard -> Edge Functions -> Secrets):
//   STRIPE_SECRET_KEY  - your Stripe TEST secret key (sk_test_...)
//
// SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY are injected
// automatically by Supabase.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY")!;

    // Scoped to the calling user, so RLS limits reads to their own rows.
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return json({ error: "Invalid session" }, 401);
    }

    const { data: student, error: studentError } = await userClient
      .from("students")
      .select("id")
      .eq("profile_id", userData.user.id)
      .single();
    if (studentError || !student) {
      return json({ error: "Student record not found" }, 404);
    }
    const studentId = student.id as number;

    const body = await req.json().catch(() => ({}));
    const mode = body?.mode;

    if (mode === "create") {
      const { data: fees, error: feesError } = await userClient
        .from("student_fees")
        .select("amount, currency")
        .eq("student_id", studentId)
        .eq("is_paid", false);
      if (feesError) return json({ error: feesError.message }, 500);

      if (!fees || fees.length === 0) {
        return json({ error: "No outstanding fees to pay" }, 400);
      }

      const total = fees.reduce(
        (sum: number, f: { amount: number }) => sum + Number(f.amount),
        0,
      );
      // Stripe expects a lowercase ISO currency code and the amount in the
      // smallest unit (e.g. piastres for EGP, cents for USD).
      const currency = (fees[0].currency || "egp").toLowerCase();

      const stripeResp = await fetch("https://api.stripe.com/v1/payment_intents", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${stripeSecretKey}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          amount: String(Math.round(total * 100)),
          currency,
          "automatic_payment_methods[enabled]": "true",
          "metadata[student_id]": String(studentId),
        }),
      });
      const stripeData = await stripeResp.json();
      if (!stripeResp.ok) {
        return json({ error: stripeData?.error?.message ?? "Stripe error" }, 400);
      }

      return json({
        clientSecret: stripeData.client_secret,
        amount: total,
        currency,
      });
    }

    if (mode === "confirm") {
      const paymentIntentId = body?.paymentIntentId;
      if (!paymentIntentId) {
        return json({ error: "paymentIntentId is required" }, 400);
      }

      const stripeResp = await fetch(
        `https://api.stripe.com/v1/payment_intents/${paymentIntentId}`,
        { headers: { "Authorization": `Bearer ${stripeSecretKey}` } },
      );
      const intent = await stripeResp.json();
      if (!stripeResp.ok) {
        return json({ error: intent?.error?.message ?? "Stripe error" }, 400);
      }

      if (intent.status !== "succeeded") {
        return json({
          success: false,
          message: `Payment not completed (status: ${intent.status})`,
        });
      }

      // Use the service role so this write succeeds regardless of the
      // student's RLS update permissions on student_fees.
      const adminClient = createClient(supabaseUrl, serviceRoleKey);
      const { error: updateError } = await adminClient
        .from("student_fees")
        .update({ is_paid: true, paid_on: new Date().toISOString() })
        .eq("student_id", studentId)
        .eq("is_paid", false);
      if (updateError) return json({ error: updateError.message }, 500);

      return json({ success: true, transactionId: paymentIntentId });
    }

    return json({ error: "Unknown mode" }, 400);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
