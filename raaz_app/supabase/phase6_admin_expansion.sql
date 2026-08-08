-- ============================================================
-- RAAZ Phase 6 — Admin Feature Expansion
-- Run in Supabase SQL Editor
-- ============================================================

-- 1. Categories Expansion (Add description and is_hidden)
ALTER TABLE public.categories 
ADD COLUMN IF NOT EXISTS description text DEFAULT '',
ADD COLUMN IF NOT EXISTS is_hidden boolean DEFAULT false;

-- 2. Global Notifications (for Push Notifications page)
CREATE TABLE IF NOT EXISTS public.global_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Admins can insert, everyone can read
ALTER TABLE public.global_notifications ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "global_notifications_read_all" ON public.global_notifications
    FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE POLICY "global_notifications_insert_admin" ON public.global_notifications
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN null;
END $$;


-- 3. Event Logs (for Realtime Analytics Dashboard)
CREATE TABLE IF NOT EXISTS public.event_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  event_name text NOT NULL, -- e.g., 'app_open', 'post_created', 'sign_up'
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.event_logs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "event_logs_insert_all" ON public.event_logs
    FOR INSERT WITH CHECK (true); -- Anyone can log an event (even anonymously if needed)
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE POLICY "event_logs_read_admin" ON public.event_logs
    FOR SELECT USING (auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN null;
END $$;


-- 4. User Challenges Tracker (to see how many completed a challenge)
CREATE TABLE IF NOT EXISTS public.user_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge_title text NOT NULL, -- using title to link since challenges don't have stable IDs historically
  completed_at timestamptz DEFAULT now(),
  UNIQUE(user_id, challenge_title)
);

ALTER TABLE public.user_challenges ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "user_challenges_read_all" ON public.user_challenges
    FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE POLICY "user_challenges_insert_own" ON public.user_challenges
    FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN null;
END $$;


-- 5. Enable Realtime for new tables and categories
ALTER PUBLICATION supabase_realtime ADD TABLE public.global_notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_challenges;
ALTER PUBLICATION supabase_realtime ADD TABLE public.categories;
ALTER PUBLICATION supabase_realtime ADD TABLE public.daily_challenges;
ALTER PUBLICATION supabase_realtime ADD TABLE public.app_config;
