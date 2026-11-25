import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
};
const normalizeKey = (key)=>{
  return key.trim().toUpperCase().replace(/[-\s]/g, '');
};
const hashKey = async (key)=>{
  const msgUint8 = new TextEncoder().encode(key);
  const hashBuffer = await crypto.subtle.digest('SHA-256', msgUint8);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b)=>b.toString(16).padStart(2, '0')).join('');
};
Deno.serve(async (req)=>{
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const supabase = createClient(supabaseUrl, supabaseKey);
    // 1. Authenticate user
    const authHeader = req.headers.get('Authorization');
    const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));
    if (authError || !user) {
      return new Response(JSON.stringify({
        error: 'Unauthorized'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 401
      });
    }
    // 2. Parse input
    const { key } = await req.json();
    if (!key) {
      return new Response(JSON.stringify({
        error: 'Key is required'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    const normalized = normalizeKey(key);
    const hashed = await hashKey(normalized);
    // 3. Find key
    const { data: keyData, error: keyError } = await supabase.from('subscription_keys').select('*').eq('key_hash', hashed).single();
    if (keyError || !keyData) {
      console.log(`Invalid key attempt by user ${user.id}: ${key.substring(0, 5)}...`);
      return new Response(JSON.stringify({
        error: 'Invalid key'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    // 4. Verify status
    const now = new Date().toISOString();
    if (keyData.revoked_at) {
      return new Response(JSON.stringify({
        error: 'Key has been revoked'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    if (keyData.valid_until && keyData.valid_until < now) {
      return new Response(JSON.stringify({
        error: 'Key has expired'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    if (keyData.valid_from && keyData.valid_from > now) {
      return new Response(JSON.stringify({
        error: 'Key is not yet active'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    if (keyData.redemption_count >= keyData.max_redemptions) {
      return new Response(JSON.stringify({
        error: 'Key has already been redeemed the maximum number of times'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    // 5. Check if THIS user already redeemed THIS key
    const { data: existingRedemption } = await supabase.from('subscription_key_redemptions').select('id').eq('key_id', keyData.id).eq('user_id', user.id).single();
    if (existingRedemption) {
      return new Response(JSON.stringify({
        error: 'You have already redeemed this key'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    // 6. Transactional Redemption
    const entitlementStart = now;
    let entitlementExpiration = null;
    if (!keyData.lifetime && keyData.duration_seconds) {
      entitlementExpiration = new Date(Date.now() + keyData.duration_seconds * 1000).toISOString();
    }
    // Use a transaction (RPC or atomic sequence)
    // Supabase doesn't support complex transactions via postgrest directly easily for multiple tables
    // We'll use a postgres function for atomicity
    const { data: result, error: rpcError } = await supabase.rpc('redeem_subscription_key_atomic', {
      p_key_id: keyData.id,
      p_user_id: user.id,
      p_entitlement_start: entitlementStart,
      p_entitlement_expiration: entitlementExpiration,
      p_plan: keyData.plan,
      p_storage_bytes: keyData.storage_bytes,
      p_lifetime: keyData.lifetime
    });
    if (rpcError) {
      console.error("Redemption RPC Error:", rpcError);
      return new Response(JSON.stringify({
        error: 'Failed to process redemption'
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 500
      });
    }
    return new Response(JSON.stringify({
      success: true,
      entitlement: {
        plan: keyData.plan,
        storage_bytes: keyData.storage_bytes,
        expires_at: entitlementExpiration,
        lifetime: keyData.lifetime
      }
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (err) {
    console.error("FUNCTION ERROR:", err);
    return new Response(JSON.stringify({
      error: 'Internal Server Error'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
