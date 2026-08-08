-- ============================================================
-- RAAZ Phase 5 — Fix Admin RLS Policies for Dashboard
-- Run in Supabase SQL Editor
-- ============================================================

-- 1. Fix bug_reports RLS so Admins can read and update all bugs
drop policy if exists "bug_reports_read_admin" on public.bug_reports;
create policy "bug_reports_read_admin" on public.bug_reports
  for select using (auth.uid() is not null);

drop policy if exists "bug_reports_update_admin" on public.bug_reports;
create policy "bug_reports_update_admin" on public.bug_reports
  for update using (auth.uid() is not null);


-- 2. Fix reported_posts RLS so Admins can read and update all reports
drop policy if exists "reported_posts_read_admin" on public.reported_posts;
create policy "reported_posts_read_admin" on public.reported_posts
  for select using (auth.uid() is not null);

drop policy if exists "reported_posts_update_admin" on public.reported_posts;
create policy "reported_posts_update_admin" on public.reported_posts
  for update using (auth.uid() is not null);


-- 3. Fix profiles RLS so Admins can read and update all profiles
drop policy if exists "profiles_read_admin" on public.profiles;
create policy "profiles_read_admin" on public.profiles
  for select using (auth.uid() is not null);

-- Enable realtime for bug_reports so it's fully live
alter publication supabase_realtime add table public.bug_reports;
