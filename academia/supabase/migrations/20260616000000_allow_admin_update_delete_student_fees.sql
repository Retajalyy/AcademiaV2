-- Admins editing/deleting a fee from the Fees & Payments admin screen have no
-- effect (0 rows affected, no error) because student_fees has RLS enabled but
-- no UPDATE/DELETE policy for admins. Add them, mirroring the admin INSERT
-- policy added in 20260615000000_allow_admin_insert_student_fees.sql.

create policy "Admins can update student fees"
  on public.student_fees
  for update
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  );

create policy "Admins can delete student fees"
  on public.student_fees
  for delete
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  );
