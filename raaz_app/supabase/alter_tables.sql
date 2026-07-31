-- Run this SQL in your Supabase SQL Editor to add the pseudonym column to reactions and comment_likes

-- 1. Add pseudonym to reactions
ALTER TABLE public.reactions 
ADD COLUMN IF NOT EXISTS pseudonym text;

-- 2. Add pseudonym to comment_likes
ALTER TABLE public.comment_likes 
ADD COLUMN IF NOT EXISTS pseudonym text;

-- (Optional) If you want to automatically set the pseudonym of existing reactions based on the user's raw_user_meta_data, 
-- you can run the following advanced queries, though they require joining on auth.users which may be restricted. 
-- For now, just adding the columns is enough for all future reactions!
