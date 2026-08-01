-- ============================================================
-- RAAZ Phase 4 — Full UI Implementation Database Support
-- ============================================================

-- TABLE: analytics_events
create table if not exists public.analytics_events (
  id uuid default gen_random_uuid() primary key,
  event_type text not null,
  event_data jsonb,
  user_id uuid references auth.users(id),
  created_at timestamp with time zone default now()
);

alter table public.analytics_events enable row level security;

create policy "analytics_insert_public" on public.analytics_events
  for insert with check (true);

create policy "analytics_read_admin" on public.analytics_events
  for select using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- TABLE: featured_stories
create table if not exists public.featured_stories (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade,
  is_active boolean default true,
  featured_by uuid references auth.users(id),
  created_at timestamp with time zone default now()
);

alter table public.featured_stories enable row level security;

create policy "featured_stories_read_public" on public.featured_stories
  for select using (true);

create policy "featured_stories_all_admin" on public.featured_stories
  for all using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- TABLE: blog_posts
create table if not exists public.blog_posts (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  slug text not null unique,
  content text not null,
  cover_image_url text,
  author_id uuid references auth.users(id),
  is_published boolean default false,
  published_at timestamp with time zone,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

alter table public.blog_posts enable row level security;

create policy "blog_posts_read_public" on public.blog_posts
  for select using (is_published = true);

create policy "blog_posts_all_admin" on public.blog_posts
  for all using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );

-- TABLE: contact_messages
create table if not exists public.contact_messages (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  email text not null,
  subject text not null,
  message text not null,
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

alter table public.contact_messages enable row level security;

create policy "contact_messages_insert_public" on public.contact_messages
  for insert with check (true);

create policy "contact_messages_read_admin" on public.contact_messages
  for select using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.is_admin = true
    )
  );
