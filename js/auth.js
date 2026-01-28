// Authentication Functions for TraceAI

// Sign Up with email and password
async function signUp(email, password, displayName) {
    try {
        const { data, error } = await supabase.auth.signUp({
            email: email,
            password: password,
            options: {
                data: {
                    display_name: displayName,
                    avatar_url: `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(email)}`
                },
                emailRedirectTo: window.location.origin + '/profile.html'
            }
        });

        if (error) throw error;

        // Profile is created automatically by database trigger
        // No need to manually create it here

        return { data, error: null };
    } catch (error) {
        console.error('Sign up error:', error);
        return { data: null, error };
    }
}

// Sign In with email and password
async function signIn(email, password) {
    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });

        if (error) throw error;
        return { data, error: null };
    } catch (error) {
        console.error('Sign in error:', error);
        return { data: null, error };
    }
}

// Sign Out
async function signOut() {
    try {
        const { error } = await supabase.auth.signOut();
        if (error) throw error;
        window.location.href = 'index.html';
    } catch (error) {
        console.error('Sign out error:', error);
    }
}

// Get current user
async function getCurrentUser() {
    try {
        const { data: { user }, error } = await supabase.auth.getUser();
        if (error) throw error;
        return user;
    } catch (error) {
        console.error('Get user error:', error);
        return null;
    }
}

// Get current session
async function getSession() {
    try {
        const { data: { session }, error } = await supabase.auth.getSession();
        if (error) throw error;
        return session;
    } catch (error) {
        console.error('Get session error:', error);
        return null;
    }
}

// Create user profile in database
async function createProfile(userId, displayName, email, avatarUrl) {
    try {
        const { data, error } = await supabase
            .from('profiles')
            .upsert({
                id: userId,
                display_name: displayName,
                email: email,
                avatar_url: avatarUrl || `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(email)}`,
                plan: 'free',
                plan_status: 'active',
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            }, { onConflict: 'id' })
            .select()
            .single();

        if (error) throw error;
        return { data, error: null };
    } catch (error) {
        console.error('Create profile error:', error);
        return { data: null, error };
    }
}

// Get user profile from database
async function getProfile(userId) {
    try {
        const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .single();

        if (error) throw error;
        return { data, error: null };
    } catch (error) {
        console.error('Get profile error:', error);
        return { data: null, error };
    }
}

// Update user profile
async function updateProfile(userId, updates) {
    try {
        const { data, error } = await supabase
            .from('profiles')
            .update({
                ...updates,
                updated_at: new Date().toISOString()
            })
            .eq('id', userId)
            .select()
            .single();

        if (error) throw error;
        return { data, error: null };
    } catch (error) {
        console.error('Update profile error:', error);
        return { data: null, error };
    }
}

// Upload avatar image
async function uploadAvatar(userId, file) {
    try {
        const fileExt = file.name.split('.').pop();
        const fileName = `${userId}/avatar.${fileExt}`;

        // Upload to Supabase Storage
        const { data: uploadData, error: uploadError } = await supabase.storage
            .from('avatars')
            .upload(fileName, file, { upsert: true });

        if (uploadError) throw uploadError;

        // Get public URL
        const { data: { publicUrl } } = supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);

        // Update profile with new avatar URL
        await updateProfile(userId, { avatar_url: publicUrl });

        return { url: publicUrl, error: null };
    } catch (error) {
        console.error('Upload avatar error:', error);
        return { url: null, error };
    }
}

// Check if user is authenticated, redirect if not
async function requireAuth() {
    const session = await getSession();
    if (!session) {
        window.location.href = 'auth.html';
        return null;
    }
    return session;
}

// Redirect to profile if already logged in
async function redirectIfLoggedIn() {
    const session = await getSession();
    if (session) {
        window.location.href = 'profile.html';
    }
}

// Listen for auth state changes
function onAuthStateChange(callback) {
    supabase.auth.onAuthStateChange((event, session) => {
        callback(event, session);
    });
}

// Password reset
async function resetPassword(email) {
    try {
        const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
            redirectTo: getRedirectUrl('reset-password.html')
        });

        if (error) throw error;
        return { data, error: null };
    } catch (error) {
        console.error('Reset password error:', error);
        return { data: null, error };
    }
}

// Helper to get redirect URL based on current environment
function getRedirectUrl(page = 'profile.html') {
    const origin = window.location.origin;
    const path = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1);
    return origin + path + page;
}
