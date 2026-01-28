// Supabase Configuration
const SUPABASE_URL = 'https://jqdexpalvcefsrwoevjr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxZGV4cGFsdmNlZnNyd29ldmpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkzNjQ3OTksImV4cCI6MjA4NDk0MDc5OX0.kiIoZwL-q0xyYUMkT_k5NEjsmcZGJ7mjz5-S5iOK3yI';

// Initialize Supabase Client
let supabase = null;

// Try different ways the Supabase library might be exposed
(function initSupabase() {
    // Check for the UMD global
    if (typeof window !== 'undefined') {
        // supabase-js v2 UMD exposes window.supabase
        if (window.supabase && typeof window.supabase.createClient === 'function') {
            supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            console.log('Supabase initialized successfully');
            return;
        }

        // Some CDN versions might expose it differently
        if (window.Supabase && typeof window.Supabase.createClient === 'function') {
            supabase = window.Supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            console.log('Supabase initialized successfully (Supabase global)');
            return;
        }

        // Check if createClient is directly on window
        if (typeof window.createClient === 'function') {
            supabase = window.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            console.log('Supabase initialized successfully (createClient global)');
            return;
        }
    }

    console.error('Supabase library not found. Available on window:', Object.keys(window).filter(k => k.toLowerCase().includes('supa')));
})();

// Helper to check if supabase is ready
function isSupabaseReady() {
    return supabase !== null && supabase.auth !== undefined;
}
