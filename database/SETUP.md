# TraceAI Supabase Setup Guide

## 1. Run the Database Schema

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor** (in the left sidebar)
3. Click **New Query**
4. Copy and paste the contents of `schema.sql`
5. Click **Run** (or press Ctrl/Cmd + Enter)

## 2. Create Storage Bucket for Avatars

1. Go to **Storage** in the left sidebar
2. Click **New Bucket**
3. Enter these settings:
   - **Name:** `avatars`
   - **Public bucket:** ✓ Check this box (for public avatar URLs)
4. Click **Create bucket**

### Set Storage Policies

After creating the bucket, set up policies:

1. Click on the `avatars` bucket
2. Click **Policies** tab
3. Click **New Policy** and add these policies:

**Policy 1: Allow public read access**
```sql
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );
```

**Policy 2: Allow authenticated users to upload**
```sql
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated'
);
```

**Policy 3: Allow users to update their own avatars**
```sql
CREATE POLICY "Users can update own avatars"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);
```

**Policy 4: Allow users to delete their own avatars**
```sql
CREATE POLICY "Users can delete own avatars"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);
```

## 3. Enable OAuth Providers (Optional)

To enable Google/GitHub sign-in:

1. Go to **Authentication** > **Providers**
2. Enable **Google**:
   - Get OAuth credentials from [Google Cloud Console](https://console.cloud.google.com/)
   - Add Client ID and Secret
3. Enable **GitHub**:
   - Get OAuth credentials from [GitHub Developer Settings](https://github.com/settings/developers)
   - Add Client ID and Secret

## 4. Configure Site URL

1. Go to **Authentication** > **URL Configuration**
2. Set **Site URL** to your production URL (or `http://localhost:3000` for development)
3. Add **Redirect URLs**:
   - `http://localhost:3000/profile.html`
   - `https://yourdomain.com/profile.html`

## 5. Email Templates (Optional)

Customize email templates in **Authentication** > **Email Templates**:
- Confirm signup
- Reset password
- Magic link

---

## Testing

1. Open `auth.html` in your browser
2. Create a new account
3. Check your email for confirmation (if email confirmation is enabled)
4. Sign in and you should be redirected to `profile.html`

## Troubleshooting

**"relation profiles does not exist"**
- Make sure you ran the schema.sql in the SQL Editor

**Avatar upload fails**
- Make sure the `avatars` storage bucket exists
- Check that storage policies are set correctly

**OAuth redirect fails**
- Check that redirect URLs are configured in Authentication settings
- Make sure OAuth provider credentials are correct
