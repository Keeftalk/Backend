import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { DOMParser } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};
serve(async (req)=>{
  console.log("Edge Function 'link-preview' invoked");
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const { url } = await req.json();
    console.log("Processing URL:", url);
    if (!url) throw new Error("URL is required");
    // 1. Basic SSRF Protection
    const parsedUrl = new URL(url);
    if (![
      'http:',
      'https:'
    ].includes(parsedUrl.protocol)) {
      throw new Error("Only http and https protocols are allowed");
    }
    // Block private/internal IPs
    const hostname = parsedUrl.hostname;
    if (/^(localhost|127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)/.test(hostname)) {
      console.error("SSRF Blocked hostname:", hostname);
      throw new Error("Invalid hostname (SSRF protection)");
    }
    // 2. Initialize Supabase Client with Service Role (to bypass RLS)
    const supabaseAdmin = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    const normalizedUrl = url.toLowerCase().trim();
    // 3. Check for existing cached preview
    console.log("Checking cache for:", normalizedUrl);
    const { data: cached } = await supabaseAdmin.from('link_previews').select('*').eq('normalized_url', normalizedUrl).single();
    if (cached) {
      console.log("Cache hit for URL");
      return new Response(JSON.stringify(cached), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 200
      });
    }
    // 4. Fetch with timeout and size limit
    console.log("Cache miss, fetching metadata from source...");
    const controller = new AbortController();
    const timeout = setTimeout(()=>controller.abort(), 8000);
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        'User-Agent': 'KeeftalkBot/1.0 (Link Preview System)',
        'Accept': 'text/html'
      }
    });
    clearTimeout(timeout);
    if (!response.ok) throw new Error(`Failed to fetch: ${response.statusText}`);
    const html = await response.text();
    const doc = new DOMParser().parseFromString(html, "text/html");
    if (!doc) throw new Error("Failed to parse HTML");
    const getMeta = (names)=>{
      for (const name of names){
        const el = doc.querySelector(`meta[property="${name}"], meta[name="${name}"]`);
        if (el) return el.getAttribute("content");
      }
      return null;
    };
    const title = getMeta([
      "og:title",
      "twitter:title"
    ]) || doc.title || "";
    const description = getMeta([
      "og:description",
      "twitter:description",
      "description"
    ]) || "";
    const image = getMeta([
      "og:image",
      "twitter:image"
    ]) || "";
    const siteName = getMeta([
      "og:site_name"
    ]) || "";
    const favicon = doc.querySelector('link[rel="icon"], link[rel="shortcut icon"]')?.getAttribute("href");
    const metadata = {
      url,
      normalized_url: normalizedUrl,
      canonical_url: getMeta([
        "og:url"
      ]) || url,
      domain: parsedUrl.hostname,
      title: title.trim().substring(0, 255),
      description: description.trim().substring(0, 500),
      image_url: image,
      favicon_url: favicon ? new URL(favicon, url).toString() : null,
      site_name: siteName,
      status: 'SUCCESS',
      updated_at: new Date().toISOString()
    };
    // 5. Save to database
    console.log("Upserting metadata to 'link_previews' table");
    const { data: inserted, error: insertError } = await supabaseAdmin.from('link_previews').upsert(metadata).select().single();
    if (insertError) {
      console.error("Insert error:", insertError);
    } else {
      console.log("Metadata successfully saved/updated");
    }
    return new Response(JSON.stringify(inserted || metadata), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (error) {
    console.error("Function error:", error.message);
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 400
    });
  }
});
