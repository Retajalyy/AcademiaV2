-- Admins creating a new fee batch from the Fees & Payments admin screen get
-- "new row violates row-level security policy for table student_fees"
-- (42501) because student_fees has RLS enabled but no INSERT policy for
-- admins. Add one, mirroring the admin role check used elsewhere
-- (profiles.role = 'admin').

create policy "Admins can insert student fees"
  on public.student_fees
  for insert
  to authenticated
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  );
