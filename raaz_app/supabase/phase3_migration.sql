-- ============================================================
-- RAAZ Phase 3 — Achievements & Daily Challenges
-- ============================================================

-- TABLE: daily_challenges
create table public.daily_challenges (
  id          uuid primary key default gen_random_uuid(),
  date        date not null unique default current_date,
  title       text not null,
  description text not null,
  topic       text not null,
  created_at  timestamptz default now()
);

-- TABLE: achievements
create table public.achievements (
  id             uuid primary key default gen_random_uuid(),
  title          text not null unique,
  description    text not null,
  icon_url       text,
  required_count int default 1,
  type           text not null check (type in ('posts', 'reactions', 'streak', 'special')),
  created_at     timestamptz default now()
);

-- TABLE: user_achievements
create table public.user_achievements (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid references auth.users(id) on delete cascade,
  achievement_id uuid references public.achievements(id) on delete cascade,
  unlocked_at    timestamptz default now(),
  unique(user_id, achievement_id)
);


-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

alter table public.daily_challenges enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;

-- daily_challenges: Read-only for all users (managed by admin)
create policy "daily_challenges_read_all" on public.daily_challenges
  for select using (true);

-- achievements: Read-only for all users (managed by admin)
create policy "achievements_read_all" on public.achievements
  for select using (true);

-- user_achievements: Users can read their own
create policy "user_achievements_read_own" on public.user_achievements
  for select using (auth.uid() = user_id);

-- user_achievements: Insert allowed via backend logic or trigger? 
-- For now, allow insert own (we'll assume client logic manages unlocking initially or trigger based)
create policy "user_achievements_insert_own" on public.user_achievements
  for insert with check (auth.uid() = user_id);

-- ============================================================
-- SEED DATA
-- ============================================================

insert into public.daily_challenges (date, title, description, topic) values
  (current_date, 'The One That Got Away', 'Share a story about a missed connection or an unsaid goodbye.', 'Confessions'),
  (current_date - interval '1 day', 'Workplace Drama', 'What is the most bizarre thing that happened at your job this week?', 'Work Life');

insert into public.achievements (title, description, icon_url, required_count, type) values
  ('First Confession', 'You shared your first secret with the world.', 'first_post_icon', 1, 'posts'),
  ('Prolific Writer', 'You shared 10 secrets.', 'prolific_icon', 10, 'posts'),
  ('Supportive Friend', 'You reacted to 50 posts.', 'support_icon', 50, 'reactions'),
  ('7-Day Streak', 'You visited RAAZ 7 days in a row.', 'streak_7_icon', 7, 'streak');
