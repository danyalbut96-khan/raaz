-- ============================================================
-- RAAZ Phase 1 — Complete Database Schema (Error Free)
-- ============================================================

-- 1. Enable UUID extension
create extension if not exists "pgcrypto";

-- ============================================================
-- 2. TABLES CREATION
-- ============================================================

-- TABLE: categories
create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  icon        text,
  sort_order  int default 0,
  created_at  timestamptz default now()
);

-- TABLE: posts
create table public.posts (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references auth.users(id) on delete cascade,
  category_id      uuid references public.categories(id),
  body             text not null,
  mood             text,
  pseudonym        text not null,
  is_featured      boolean default false,
  is_ghost_mode    boolean default false,
  allow_comments   boolean default true,
  allow_sharing    boolean default true,
  is_deleted       boolean default false,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- TABLE: reactions
create table public.reactions (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid references public.posts(id) on delete cascade,
  user_id    uuid references auth.users(id) on delete cascade,
  type       text not null check (type in ('care','insightful','support','laugh','shock')),
  created_at timestamptz default now(),
  unique(post_id, user_id)
);

-- TABLE: comments
create table public.comments (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid references public.posts(id) on delete cascade,
  parent_id   uuid references public.comments(id) on delete cascade,
  user_id     uuid references auth.users(id) on delete cascade,
  body        text not null,
  pseudonym   text not null,
  is_deleted  boolean default false,
  created_at  timestamptz default now()
);

-- TABLE: comment_likes
create table public.comment_likes (
  id          uuid primary key default gen_random_uuid(),
  comment_id  uuid references public.comments(id) on delete cascade,
  user_id     uuid references auth.users(id) on delete cascade,
  created_at  timestamptz default now(),
  unique(comment_id, user_id)
);

-- TABLE: bookmarks
create table public.bookmarks (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade,
  post_id    uuid references public.posts(id) on delete cascade,
  created_at timestamptz default now(),
  unique(user_id, post_id)
);

-- TABLE: reports
create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete cascade,
  post_id     uuid references public.posts(id) on delete set null,
  comment_id  uuid references public.comments(id) on delete set null,
  reason      text not null check (reason in ('spam','hate_speech','harassment','misinformation','other')),
  status      text default 'pending' check (status in ('pending','reviewed','dismissed')),
  created_at  timestamptz default now()
);


-- ============================================================
-- 3. VIEWS & TRIGGERS
-- ============================================================

-- Trending score view (must be created AFTER reactions and comments tables)
create or replace view public.posts_trending as
select
  p.*,
  coalesce(r.reaction_count, 0) + (coalesce(c.comment_count, 0) * 2) as trending_score
from public.posts p
left join (
  select post_id, count(*) as reaction_count
  from public.reactions
  group by post_id
) r on r.post_id = p.id
left join (
  select post_id, count(*) as comment_count
  from public.comments
  where created_at > now() - interval '48 hours'
  group by post_id
) c on c.post_id = p.id
where p.is_deleted = false
  and p.is_ghost_mode = false
  and p.created_at > now() - interval '48 hours';


-- UPDATED_AT trigger for posts
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger posts_updated_at
  before update on public.posts
  for each row execute procedure public.handle_updated_at();


-- ============================================================
-- 4. INITIAL DATA INSERTION
-- ============================================================
insert into public.categories (name, icon, sort_order) values
  ('Confessions',  'lock',         1),
  ('Rants',        'bolt',         2),
  ('Questions',    'help',         3),
  ('Advice',       'lightbulb',    4),
  ('Random',       'shuffle',      5),
  ('Work Life',    'work',         6),
  ('Relationships','favorite',     7),
  ('Deep Thoughts','psychology',   8),
  ('Life Hacks',   'tips_and_updates', 9)
on conflict (name) do nothing;


-- ============================================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================================

alter table public.categories enable row level security;
alter table public.posts enable row level security;
alter table public.reactions enable row level security;
alter table public.comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.bookmarks enable row level security;
alter table public.reports enable row level security;

-- Categories
create policy "categories_read_all" on public.categories
  for select using (true);

-- Posts
create policy "posts_read_all" on public.posts
  for select using (is_deleted = false);

create policy "posts_insert_own" on public.posts
  for insert with check (auth.uid() = user_id);

create policy "posts_update_own" on public.posts
  for update using (auth.uid() = user_id);

create policy "posts_delete_own" on public.posts
  for delete using (auth.uid() = user_id);

-- Reactions
create policy "reactions_read_all" on public.reactions
  for select using (true);

create policy "reactions_insert_own" on public.reactions
  for insert with check (auth.uid() = user_id);

create policy "reactions_delete_own" on public.reactions
  for delete using (auth.uid() = user_id);

-- Comments
create policy "comments_read_all" on public.comments
  for select using (is_deleted = false);

create policy "comments_insert_own" on public.comments
  for insert with check (auth.uid() = user_id);

create policy "comments_delete_own" on public.comments
  for delete using (auth.uid() = user_id);

-- Comment likes
create policy "comment_likes_read_all" on public.comment_likes
  for select using (true);

create policy "comment_likes_insert_own" on public.comment_likes
  for insert with check (auth.uid() = user_id);

create policy "comment_likes_delete_own" on public.comment_likes
  for delete using (auth.uid() = user_id);

-- Bookmarks
create policy "bookmarks_read_own" on public.bookmarks
  for select using (auth.uid() = user_id);

create policy "bookmarks_insert_own" on public.bookmarks
  for insert with check (auth.uid() = user_id);

create policy "bookmarks_delete_own" on public.bookmarks
  for delete using (auth.uid() = user_id);

-- Reports
create policy "reports_insert_own" on public.reports
  for insert with check (auth.uid() = reporter_id);


-- ============================================================
-- 6. REALTIME: Enable for key tables
-- ============================================================
alter publication supabase_realtime add table public.posts;
alter publication supabase_realtime add table public.comments;
alter publication supabase_realtime add table public.reactions;
