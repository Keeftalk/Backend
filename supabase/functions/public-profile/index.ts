import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
};
Deno.serve(async (req)=>{
  // 1. ALWAYS handle OPTIONS first for CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !supabaseKey) {
      console.error("CRITICAL: Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
      return new Response(JSON.stringify({
        error: 'Server configuration error'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 500
      });
    }
    const supabase = createClient(supabaseUrl, supabaseKey);
    const url = new URL(req.url);
    const username = url.searchParams.get('username');
    const query = url.searchParams.get('q');
    console.log(`Request: ${req.method} | username=${username} | query=${query}`);
    // --- SEARCH MODE ---
    if (query) {
      const trimmedQuery = query.trim();
      console.log(`Processing search query: "${trimmedQuery}"`);
      const isEmail = trimmedQuery.includes('@');
      const isPhone = /^\+?[\d\s-]{8,}$/.test(trimmedQuery);
      let dbQuery = supabase.from('profiles').select('*');
      if (isEmail) {
        dbQuery = dbQuery.eq('email', trimmedQuery);
      } else if (isPhone) {
        dbQuery = dbQuery.eq('phone', trimmedQuery.replace(/\s+/g, ''));
      } else {
        dbQuery = dbQuery.or(`username.ilike.%${trimmedQuery}%,full_name.ilike.%${trimmedQuery}%`);
      }
      const { data: profiles, error: searchError } = await dbQuery.limit(20);
      if (searchError) {
        console.error("Search Error:", searchError);
        return new Response(JSON.stringify({
          error: searchError.message
        }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 400
        });
      }
      if (!profiles || profiles.length === 0) {
        return new Response(JSON.stringify([]), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 200
        });
      }
      const userIds = profiles.map((p)=>p.id);
      const [{ data: allPrivacy }, { data: allSettings }] = await Promise.all([
        supabase.from('user_privacy_settings').select('*').in('user_id', userIds),
        supabase.from('user_settings').select('user_id, privacy_settings, parental_controls').in('user_id', userIds)
      ]);
      const results = profiles.map((profile)=>{
        // Try to find privacy settings in both tables (migration support)
        const privacyRow = allPrivacy?.find((p)=>p.user_id === profile.id);
        const settingsRow = allSettings?.find((s)=>s.user_id === profile.id);
        const privacy = privacyRow || settingsRow?.privacy_settings || {};
        const parental = settingsRow?.parental_controls || {};
        const isHidden = parental.hide_profile_from_search === true || privacy.profile_visibility === 'NOBODY';
        if (isHidden) return null;
        const isPublic = (v)=>(v || 'EVERYONE') === 'EVERYONE';
        return {
          username: profile.username,
          full_name: profile.full_name,
          avatar_url: isPublic(privacy.profile_photo_visibility) ? profile.avatar_url : null,
          is_verified: profile.is_verified || false,
          avatar_hidden: !isPublic(privacy.profile_photo_visibility)
        };
      }).filter((r)=>r !== null);
      return new Response(JSON.stringify(results), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 200
      });
    }
    // --- SINGLE PROFILE MODE ---
    if (username) {
      console.log(`Processing profile fetch for: "${username}"`);
      const { data: profiles, error: profileError } = await supabase.from('profiles').select('*').eq('username', username).limit(1);
      if (profileError) throw profileError;
      const profile = profiles?.[0];
      if (!profile) {
        console.log(`User not found: ${username}`);
        return new Response(JSON.stringify({
          error: 'USER_NOT_FOUND'
        }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 404
        });
      }
      const [{ data: privacyRows }, { data: settingsRows }] = await Promise.all([
        supabase.from('user_privacy_settings').select('*').eq('user_id', profile.id).limit(1),
        supabase.from('user_settings').select('*').eq('user_id', profile.id).limit(1)
      ]);
      const privacyRow = privacyRows?.[0];
      const settingsRow = settingsRows?.[0];
      const privacy = privacyRow || settingsRow?.privacy_settings || {
        profile_photo_visibility: 'EVERYONE',
        about_visibility: 'EVERYONE',
        connections_visibility: 'EVERYONE'
      };
      const parental = settingsRow?.parental_controls || {};
      const isPublic = (v)=>(v || 'EVERYONE') === 'EVERYONE';
      const publicProfile = {
        username: profile.username,
        full_name: profile.full_name,
        avatar_url: isPublic(privacy.profile_photo_visibility) ? profile.avatar_url : null,
        cover_url: isPublic(privacy.cover_visibility || 'EVERYONE') ? profile.cover_url : null,
        bio: isPublic(privacy.about_visibility) ? profile.bio : null,
        is_verified: profile.is_verified || false,
        join_date: profile.join_date || profile.created_at,
        is_private: privacy.profile_visibility === 'NOBODY' || parental.hide_profile_from_search === true,
        avatar_hidden: !isPublic(privacy.profile_photo_visibility),
        bio_hidden: !isPublic(privacy.about_visibility)
      };
      return new Response(JSON.stringify(publicProfile), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 200
      });
    }
    return new Response(JSON.stringify({
      error: 'Username or query parameter is required'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 400
    });
  } catch (err) {
    console.error("CATCH-ALL ERROR:", err);
    return new Response(JSON.stringify({
      error: err.message || 'Internal Server Error'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
