-- TraceAI Database Schema for Supabase
-- Run this in your Supabase SQL Editor (Database > SQL Editor)

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,

    -- Plan information
    plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
    plan_status TEXT DEFAULT 'active' CHECK (plan_status IN ('active', 'trial', 'expired', 'cancelled')),
    trial_days_remaining INTEGER DEFAULT 0,

    -- Social links
    youtube_url TEXT,
    github_url TEXT,
    website_url TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
    ON public.profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Policy: Admin can view all profiles
CREATE POLICY "Admin can view all profiles"
    ON public.profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.email = 'blazerkey106@gmail.com'
        )
    );

-- Policy: Admin can update all profiles
CREATE POLICY "Admin can update all profiles"
    ON public.profiles
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.email = 'blazerkey106@gmail.com'
        )
    );

-- ============================================
-- 3. AUTO-CREATE PROFILE ON USER SIGNUP
-- ============================================
-- This function creates a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', SPLIT_PART(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', 'https://api.dicebear.com/7.x/avataaars/svg?seed=' || NEW.email)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function on new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 4. UPDATED_AT TRIGGER
-- ============================================
-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 5. PROJECTS TABLE (for future use)
-- ============================================
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    project_data JSONB DEFAULT '{}',
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for projects
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own projects
CREATE POLICY "Users can view own projects"
    ON public.projects
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can view public projects
CREATE POLICY "Anyone can view public projects"
    ON public.projects
    FOR SELECT
    USING (is_public = true);

-- Policy: Users can insert their own projects
CREATE POLICY "Users can insert own projects"
    ON public.projects
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own projects
CREATE POLICY "Users can update own projects"
    ON public.projects
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Policy: Users can delete their own projects
CREATE POLICY "Users can delete own projects"
    ON public.projects
    FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger for projects updated_at
DROP TRIGGER IF EXISTS update_projects_updated_at ON public.projects;
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON public.projects
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 6. LIBRARIES TABLE (for future use)
-- ============================================
CREATE TABLE IF NOT EXISTS public.libraries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    components JSONB DEFAULT '[]',
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for libraries
ALTER TABLE public.libraries ENABLE ROW LEVEL SECURITY;

-- Policies for libraries (similar to projects)
CREATE POLICY "Users can view own libraries"
    ON public.libraries FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view public libraries"
    ON public.libraries FOR SELECT USING (is_public = true);

CREATE POLICY "Users can insert own libraries"
    ON public.libraries FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own libraries"
    ON public.libraries FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own libraries"
    ON public.libraries FOR DELETE USING (auth.uid() = user_id);

-- Trigger for libraries updated_at
DROP TRIGGER IF EXISTS update_libraries_updated_at ON public.libraries;
CREATE TRIGGER update_libraries_updated_at
    BEFORE UPDATE ON public.libraries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 7. CONTACT SUBMISSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.contact_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for contact_submissions
ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert (submit contact form)
CREATE POLICY "Anyone can submit contact form"
    ON public.contact_submissions
    FOR INSERT
    WITH CHECK (true);

-- Policy: Only admin can view submissions (check by email in auth.users)
CREATE POLICY "Admin can view submissions"
    ON public.contact_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.email = 'blazerkey106@gmail.com'
        )
    );

-- Policy: Only admin can update submissions
CREATE POLICY "Admin can update submissions"
    ON public.contact_submissions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.email = 'blazerkey106@gmail.com'
        )
    );

-- Policy: Only admin can delete submissions
CREATE POLICY "Admin can delete submissions"
    ON public.contact_submissions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.email = 'blazerkey106@gmail.com'
        )
    );

-- ============================================
-- 8. FORUM POSTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.forum_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('general', 'showcase', 'help', 'feedback', 'tutorials')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    is_pinned BOOLEAN DEFAULT false,
    upvotes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for forum_posts
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view forum posts
CREATE POLICY "Anyone can view forum posts"
    ON public.forum_posts
    FOR SELECT
    USING (true);

-- Policy: Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
    ON public.forum_posts
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own posts
CREATE POLICY "Users can update own posts"
    ON public.forum_posts
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Policy: Users can delete their own posts
CREATE POLICY "Users can delete own posts"
    ON public.forum_posts
    FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger for forum_posts updated_at
DROP TRIGGER IF EXISTS update_forum_posts_updated_at ON public.forum_posts;
CREATE TRIGGER update_forum_posts_updated_at
    BEFORE UPDATE ON public.forum_posts
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 9. FORUM REPLIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.forum_replies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES public.forum_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    upvotes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for forum_replies
ALTER TABLE public.forum_replies ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view replies
CREATE POLICY "Anyone can view replies"
    ON public.forum_replies
    FOR SELECT
    USING (true);

-- Policy: Authenticated users can create replies
CREATE POLICY "Authenticated users can reply"
    ON public.forum_replies
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own replies
CREATE POLICY "Users can update own replies"
    ON public.forum_replies
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Policy: Users can delete their own replies
CREATE POLICY "Users can delete own replies"
    ON public.forum_replies
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- DONE! Your database is ready.
-- ============================================
