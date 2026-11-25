import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
console.log("--- APP SYNC ENGINE BOOTING ---");
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
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
    // 1. Validate User JWT
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) throw new Error('No auth header');
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
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
    const userId = user.id;
    console.log(`Syncing data for user: ${userId}`);
    // 2. Fetch everything in parallel
    const [{ data: profile }, { data: memberships }, { data: calendar }, { data: notes }, { data: vault }] = await Promise.all([
      supabase.from('profiles').select('*').eq('id', userId).single(),
      supabase.from('chat_members').select(`
          chat_id,
          chats (
            id, name, avatar_url, type, last_message_text, last_message_time_ms,
            chat_members (
              user_id,
              profiles (id, full_name, username, avatar_url)
            )
          )
        `).eq('user_id', userId).order('chats(last_message_time_ms)', {
        ascending: false
      }).limit(15),
      supabase.from('calendar_items').select('*').eq('user_id', userId).order('start_time', {
        ascending: true
      }).limit(50),
      supabase.from('notes').select('*').eq('owner_id', userId).order('updated_at', {
        ascending: false
      }).limit(50),
      supabase.from('vault_items').select('*, files(*)').eq('user_id', userId).order('created_at', {
        ascending: false
      }).limit(20)
    ]);
    // 3. Process Chats (Resolve ONE_TO_ONE names/avatars)
    const chats = memberships?.map((m)=>{
      const chat = m.chats;
      if (chat.type === 'ONE_TO_ONE') {
        const other = chat.chat_members.find((cm)=>cm.user_id !== userId)?.profiles;
        if (other) {
          chat.name = other.full_name || other.username;
          chat.avatar_url = other.avatar_url;
        }
      }
      return chat;
    }).sort((a, b)=>(b.last_message_time_ms || 0) - (a.last_message_time_ms || 0)) || [];
    const responseData = {
      profile,
      chats,
      calendar: calendar || [],
      notes: notes || [],
      vault: vault || []
    };
    console.log(`Sync complete. Returning ${chats.length} chats, ${responseData.notes.length} notes.`);
    return new Response(JSON.stringify(responseData), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (err) {
    console.error("SYNC ERROR:", err);
    return new Response(JSON.stringify({
      error: err.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
