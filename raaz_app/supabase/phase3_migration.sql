-- ============================================================
-- RAAZ Phase 3 — Achievements, Challenges, Reports & Drafts
-- Run in Supabase SQL Editor after schema.sql + phase2_migration.sql
-- ============================================================

-- ─── 1. achievements ─────────────────────────────────────────
create table if not exists public.achievements (
  id                uuid primary key default gen_random_uuid(),
  slug              text not null unique,
  title             text not null,
  description       text not null,
  icon              text default 'emoji_events',
  xp_reward         int default 100,
  category          text default 'general',
  requirement_count int default 1,
  is_hidden         boolean default false,
  created_at        timestamptz default now()
);

-- ─── 2. user_achievements ────────────────────────────────────
create table if not exists public.user_achievements (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references auth.users(id) on delete cascade not null,
  achievement_id  uuid references public.achievements(id) on delete cascade not null,
  progress        int default 0,
  unlocked_at     timestamptz,
  created_at      timestamptz default now(),
  unique (user_id, achievement_id)
);

-- ─── 3. daily_challenges ─────────────────────────────────────
create table if not exists public.daily_challenges (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text,
  date        date not null default current_date,
  xp_reward   int default 50,
  difficulty  text default 'medium'
              check (difficulty in ('easy', 'medium', 'hard')),
  is_active   boolean default true,
  created_at  timestamptz default now()
);

-- ─── 4. reported_posts (user-facing report status) ───────────
create table if not exists public.reported_posts (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid references auth.users(id) on delete cascade not null,
  post_id      uuid references public.posts(id) on delete set null,
  comment_id   uuid references public.comments(id) on delete set null,
  reason       text not null
               check (reason in ('spam', 'hate_speech', 'harassment', 'misinformation', 'other')),
  status       text default 'pending'
               check (status in ('pending', 'under_review', 'resolved', 'dismissed')),
  admin_notes  text,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

create or replace function public.handle_reported_posts_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists reported_posts_updated_at on public.reported_posts;
create trigger reported_posts_updated_at
  before update on public.reported_posts
  for each row execute procedure public.handle_reported_posts_updated_at();

-- ─── 5. drafts (optional cloud sync) ─────────────────────────
create table if not exists public.drafts (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id) on delete cascade not null,
  body         text not null,
  category_id  uuid references public.categories(id) on delete set null,
  mood         text,
  is_published boolean default false,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

create or replace function public.handle_drafts_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists drafts_updated_at on public.drafts;
create trigger drafts_updated_at
  before update on public.drafts
  for each row execute procedure public.handle_drafts_updated_at();

-- ─── 6. RLS ──────────────────────────────────────────────────
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.daily_challenges enable row level security;
alter table public.reported_posts enable row level security;
alter table public.drafts enable row level security;

create policy "achievements_read_all" on public.achievements
  for select using (true);

create policy "user_achievements_read_own" on public.user_achievements
  for select using (auth.uid() = user_id);

create policy "user_achievements_insert_own" on public.user_achievements
  for insert with check (auth.uid() = user_id);

create policy "user_achievements_update_own" on public.user_achievements
  for update using (auth.uid() = user_id);

create policy "daily_challenges_read_all" on public.daily_challenges
  for select using (is_active = true);

create policy "reported_posts_read_own" on public.reported_posts
  for select using (auth.uid() = reporter_id);

create policy "reported_posts_insert_own" on public.reported_posts
  for insert with check (auth.uid() = reporter_id);

create policy "drafts_read_own" on public.drafts
  for select using (auth.uid() = user_id);

create policy "drafts_insert_own" on public.drafts
  for insert with check (auth.uid() = user_id);

create policy "drafts_update_own" on public.drafts
  for update using (auth.uid() = user_id);

create policy "drafts_delete_own" on public.drafts
  for delete using (auth.uid() = user_id);

-- ─── 7. Seed achievements ────────────────────────────────────
insert into public.achievements (slug, title, description, icon, xp_reward, category, requirement_count) values
  ('explorer',    'Explorer',    'Visited 50 secret circles',        'explore',         200, 'engagement', 50),
  ('writer',      'Writer',      'Shared 100 deep thoughts',         'edit_note',       500, 'content',    100),
  ('supporter',   'Supporter',   'Gave 500 digital hugs',            'favorite',        300, 'community',  500),
  ('kind_soul',   'Kind Soul',   'Maintained a clean record',        'auto_awesome',    150, 'safety',     1),
  ('truth_seeker','Truth Seeker','Read 10 posts in one session',     'search',          100, 'engagement', 10),
  ('night_owl',   'Night Owl',   'Active after midnight 30 times',   'dark_mode',       250, 'engagement', 30),
  ('first_post',  'First Voice', 'Published your first confession',    'campaign',         50, 'content',    1),
  ('hidden_gem',  'Hidden Gem',  'Unlock by sharing authentically',    'help_center',     500, 'special',    1)
on conflict (slug) do nothing;

-- ─── 8. Seed daily challenges ────────────────────────────────
insert into public.daily_challenges (title, description, date, xp_reward, difficulty)
select v.title, v.description, v.date, v.xp_reward, v.difficulty
from (values
  ('Share one positive memory'::text, 'Reflect on a moment that made you smile today.'::text, current_date - 1, 50, 'easy'::text),
  ('Confess something anonymously', 'Let go of a secret weighing on you. Your identity is protected.', current_date, 100, 'hard'),
  ('Reply to 3 anonymous posts', 'Offer empathy to three strangers in the feed.', current_date + 1, 75, 'medium')
) as v(title, description, date, xp_reward, difficulty)
where not exists (
  select 1 from public.daily_challenges dc where dc.date = v.date and dc.title = v.title
);

-- ─── 9. Realtime (optional) ──────────────────────────────────
alter publication supabase_realtime add table public.reported_posts;

-- ─── 10. Maintenance mode config ─────────────────────────────
insert into public.app_config (key, value) values
  ('maintenance_mode', 'false'),
  ('maintenance_message', 'We are performing scheduled maintenance to improve your experience.')
on conflict (key) do nothing;
