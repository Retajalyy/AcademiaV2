-- Force students/professors to change their password the first time they log in.

-- 1. Add the flag. New rows default to true (must change password),
--    matching newly created accounts that still use an admin-assigned password.
alter table public.profiles
  add column if not exists must_change_password boolean not null default true;

-- 2. Existing accounts have already been onboarded — don't force them through
--    the new flow retroactively.
update public.profiles
set must_change_password = false
where must_change_password is distinct from false;

-- 3. Let an authenticated user clear their own flag once they've set a new
--    password (security definer so it can update profiles regardless of the
--    row-level update policy on that table).
create or replace function public.mark_password_changed()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set must_change_password = false
  where id = auth.uid();
end;
$$;

grant execute on function public.mark_password_changed() to authenticated;
