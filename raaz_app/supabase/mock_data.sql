-- ============================================================
-- RAAZ MOCK DATA
-- Run this in your Supabase SQL Editor AFTER running schema.sql
-- It adds 15 mock users and ~40 mock posts across categories
-- ============================================================

-- 1. Create Mock Users (Anonymous) in auth.users
-- We will generate 15 UUIDs and insert them directly into auth.users
DO $$
DECLARE
  mock_users uuid[] := array[
    gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid(),
    gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid(),
    gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid()
  ];
  cat_ids uuid[];
  u uuid;
  c uuid;
  i int;
  p_id uuid;
BEGIN
  -- Insert 15 users into auth.users
  FOREACH u IN ARRAY mock_users
  LOOP
    INSERT INTO auth.users (id, instance_id, aud, role, created_at, updated_at, email)
    VALUES (u, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', now(), now(), 'mock_' || u || '@example.com');
  END LOOP;

  -- Get Category IDs
  SELECT array_agg(id) INTO cat_ids FROM public.categories;

  IF cat_ids IS NULL OR array_length(cat_ids, 1) = 0 THEN
    RAISE EXCEPTION 'Categories not found. Please run schema.sql first.';
  END IF;

  -- 2. Insert ~40-50 Posts
  FOR i IN 1..45 LOOP
    -- Pick a random user
    u := mock_users[1 + mod(abs(random()::int), 15)];
    -- Pick a random category
    c := cat_ids[1 + mod(abs(random()::int), array_length(cat_ids, 1))];
    
    INSERT INTO public.posts (
      id, user_id, category_id, body, pseudonym, mood, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      u,
      c,
      CASE mod(i, 5)
        WHEN 0 THEN 'I have been pretending to know what I''m doing at work for 2 years. Nobody has noticed yet. It''s exhausting but also hilarious.'
        WHEN 1 THEN 'Does anyone else feel like they are just waiting for their real life to begin? Like this is all just a tutorial level?'
        WHEN 2 THEN 'My boss just took credit for my project again. I smiled and nodded, but I''m updating my resume tonight.'
        WHEN 3 THEN 'I secretly judge people who put milk in their tea before the water. It''s just wrong on so many levels.'
        ELSE 'Sometimes I go for a drive at night just to scream in my car where nobody can hear me. It''s the best therapy.'
      END || ' (' || i || ')',
      CASE mod(i, 3)
        WHEN 0 THEN 'Silent Fox'
        WHEN 1 THEN 'Midnight Owl'
        ELSE 'Wandering Ghost'
      END,
      CASE mod(i, 4)
        WHEN 0 THEN '🤔'
        WHEN 1 THEN '🔥'
        WHEN 2 THEN '😴'
        ELSE '😊'
      END,
      now() - (i || ' hours')::interval,
      now() - (i || ' hours')::interval
    ) RETURNING id INTO p_id;

    -- Add a couple of comments to each post
    INSERT INTO public.comments (post_id, user_id, body, pseudonym, created_at)
    VALUES (
      p_id,
      mock_users[1 + mod(abs(random()::int), 15)],
      'I totally relate to this! You are not alone.',
      'Brave Pilgrim',
      now() - ((i - 1) || ' hours')::interval
    );

    INSERT INTO public.comments (post_id, user_id, body, pseudonym, created_at)
    VALUES (
      p_id,
      mock_users[1 + mod(abs(random()::int), 15)],
      'Honestly, same. It gets better though.',
      'Distant Star',
      now() - ((i - 1) || ' hours')::interval
    );

    -- Add some reactions
    INSERT INTO public.reactions (post_id, user_id, type)
    VALUES (p_id, mock_users[1 + mod(abs(random()::int), 15)], 'care')
    ON CONFLICT (post_id, user_id) DO NOTHING;

    INSERT INTO public.reactions (post_id, user_id, type)
    VALUES (p_id, mock_users[1 + mod(abs(random()::int), 15)], 'support')
    ON CONFLICT (post_id, user_id) DO NOTHING;

  END LOOP;

END $$;
