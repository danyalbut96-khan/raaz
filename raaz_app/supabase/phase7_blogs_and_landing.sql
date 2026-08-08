-- Phase 7: Blog Posts & Complete Realtime Database Schema

-- 1. Create blog_posts Table if not exists
CREATE TABLE IF NOT EXISTS public.blog_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    summary TEXT,
    content TEXT NOT NULL,
    cover_image_url TEXT,
    author_name TEXT DEFAULT 'RAAZ Team',
    tags TEXT[] DEFAULT '{}',
    is_published BOOLEAN DEFAULT true,
    published_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on blog_posts
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- Read policy: Anyone can read published blog posts
CREATE POLICY "Public can read published blog posts"
    ON public.blog_posts FOR SELECT
    USING (is_published = true OR auth.role() = 'service_role');

-- Admin write policy
CREATE POLICY "Admins can manage blog posts"
    ON public.blog_posts FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.user_id = auth.uid()
            AND profiles.role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.user_id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- 2. Realtime Enablement for blog_posts
ALTER PUBLICATION supabase_realtime ADD TABLE public.blog_posts;

-- 3. Ensure all default config keys exist in app_config
INSERT INTO public.app_config (key, value) VALUES
    ('maintenance_mode', 'false'),
    ('ads_enabled', 'true'),
    ('admob_android_id', 'ca-app-pub-3940256099942544/6300978111'),
    ('admob_ios_id', 'ca-app-pub-3940256099942544/2934735716'),
    ('ad_frequency', '5'),
    ('app_name', 'RAAZ'),
    ('app_version', '1.0.0'),
    ('force_update', 'false'),
    ('landing_hero_headline', 'Share Secrets. Stay 100% Anonymous.'),
    ('landing_hero_subheadline', 'The premier anonymous confession and support network built for complete privacy.')
ON CONFLICT (key) DO NOTHING;
