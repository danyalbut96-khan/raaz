-- ============================================================
-- RAAZ Phase 2 — Additional Tables Migration (IDEMPOTENT)
-- Safe to run multiple times. Run in the Supabase SQL Editor.
-- ============================================================

-- ─── Helper: drop a policy safely ────────────────────────────
-- (Postgres has no DROP POLICY IF EXISTS before v15, so we use DO blocks)


-- ─── 1. notifications ────────────────────────────────────────
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  type       text not null check (type in ('comment','reaction','trending','system','activity')),
  title      text not null,
  body       text,
  post_id    uuid references public.posts(id) on delete set null,
  is_read    boolean default false,
  created_at timestamptz default now()
);

alter table public.notifications enable row level security;

do $$ begin
  create policy "notifications_read_own" on public.notifications
    for select using (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "notifications_update_own" on public.notifications
    for update using (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "notifications_insert_service" on public.notifications
    for insert with check (true);
exception when duplicate_object then null;
end $$;

-- Realtime (safe to call multiple times)
do $$ begin
  alter publication supabase_realtime add table public.notifications;
exception when others then null;
end $$;


-- ─── 2. user_settings ────────────────────────────────────────
create table if not exists public.user_settings (
  user_id               uuid primary key references auth.users(id) on delete cascade,
  theme                 text default 'system' check (theme in ('system','light','dark')),
  language              text default 'en',
  privacy_level         text default 'high' check (privacy_level in ('high','medium','ghost')),
  notifications_enabled boolean default true,
  reactions_enabled     boolean default true,
  comments_enabled      boolean default true,
  updated_at            timestamptz default now()
);

alter table public.user_settings enable row level security;

do $$ begin
  create policy "user_settings_read_own" on public.user_settings
    for select using (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "user_settings_insert_own" on public.user_settings
    for insert with check (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "user_settings_update_own" on public.user_settings
    for update using (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;


-- ─── 3. profiles (anonymous reputation) ──────────────────────
create table if not exists public.profiles (
  user_id          uuid primary key references auth.users(id) on delete cascade,
  reputation_score int default 0,
  member_since     timestamptz default now(),
  updated_at       timestamptz default now()
);

alter table public.profiles enable row level security;

do $$ begin
  create policy "profiles_read_all" on public.profiles
    for select using (true);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "profiles_insert_own" on public.profiles
    for insert with check (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "profiles_update_own" on public.profiles
    for update using (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;


-- ─── 4. Auto-create profile & settings on new user sign-up ───
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- ─── 5. app_config (for version & dynamic config) ────────────
create table if not exists public.app_config (
  key        text primary key,
  value      text not null,
  updated_at timestamptz default now()
);

alter table public.app_config enable row level security;

do $$ begin
  create policy "app_config_read_all" on public.app_config
    for select using (true);
exception when duplicate_object then null;
end $$;

insert into public.app_config (key, value)
values ('app_version', 'v1.0.0')
on conflict (key) do update set value = excluded.value;


-- ─── 6. bug_reports ──────────────────────────────────────────
create table if not exists public.bug_reports (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete set null,
  description text not null,
  created_at  timestamptz default now()
);

alter table public.bug_reports enable row level security;

do $$ begin
  create policy "bug_reports_insert_own" on public.bug_reports
    for insert with check (auth.uid() = user_id or user_id is null);
exception when duplicate_object then null;
end $$;

do $$ begin
  create policy "bug_reports_read_own" on public.bug_reports
    for select using (auth.uid() = user_id);
exception when duplicate_object then null;
end $$;
