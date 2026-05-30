/// <reference lib="deno.ns" />

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const SYSTEM_PROMPT = `You are Advisa, a smart and friendly AI assistant built into the Academia university student portal.

You help students with:
- Grades, GPA, and academic performance questions
- Course registration and enrollment guidance
- Exam schedules and study tips
- Fee payments and financial queries
- Class schedules and timetables
- General university life and academic advice

Guidelines:
- Be concise and direct — students are busy
- Use bullet points for multi-step answers
- Be encouraging and supportive
- If asked something outside academic topics, gently redirect back to academic support
- Never make up specific data about the student — only answer based on what they tell you`

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { messages } = await req.json()

    const groqKey = Deno.env.get('GROQ_API_KEY')
    if (!groqKey) throw new Error('GROQ_API_KEY secret is not set')

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${groqKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.1-8b-instant',
        max_tokens: 1024,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          ...messages,
        ],
      }),
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.error?.message ?? 'Groq API error')
    }

    const text: string = data.choices[0].message.content

    // Return same shape so Flutter service code is unchanged
    return new Response(
      JSON.stringify({ content: [{ text }] }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err)
    return new Response(
      JSON.stringify({ error: message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
