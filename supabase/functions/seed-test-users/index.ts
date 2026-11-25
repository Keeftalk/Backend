import { createClient } from "npm:@supabase/supabase-js@2.45.4";
const NAMES = [
  "Ava",
  "Noah",
  "Mia",
  "Ethan",
  "Sofia",
  "Liam",
  "Isabella",
  "Oliver",
  "Charlotte",
  "Lucas",
  "Amelia",
  "Henry",
  "Harper",
  "Elijah",
  "Emily",
  "James",
  "Abigail",
  "Benjamin",
  "Ella",
  "Daniel",
  "Chloe",
  "Matthew",
  "Layla",
  "David"
];
const LAST_NAMES = [
  "Johnson",
  "Smith",
  "Brown",
  "Taylor",
  "Anderson",
  "Thomas",
  "Jackson",
  "White",
  "Harris",
  "Martin",
  "Thompson",
  "Garcia",
  "Martinez",
  "Robinson",
  "Clark",
  "Rodriguez",
  "Lewis",
  "Lee",
  "Walker",
  "Hall"
];
const COUNTRIES = [
  "US",
  "CA",
  "GB",
  "DE",
  "FR",
  "ES",
  "IT",
  "NL",
  "SE",
  "BR",
  "IN",
  "AU"
];
const bios = [
  "Building cool things ✨",
  "Coffee, code, repeat ☕️",
  "Always learning. Always shipping.",
  "If it works, make it faster.",
  "Design-minded engineer.",
  "Here for good conversations.",
  "Shipping daily.",
  "Tech + travel + music."
];
function randInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
function pick(arr) {
  return arr[randInt(0, arr.length - 1)];
}
function slugify(s) {
  return s.trim().toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "").slice(0, 24);
}
function fakeEmail(i, first, last) {
  const domain = pick([
    "example.com",
    "mail.test",
    "inbox.local",
    "devmail.io"
  ]);
  return `${first}.${last}.${i}@${domain}`.toLowerCase();
}
function fakePhone() {
  // E.164-ish formatting (no validation here)
  const cc = pick([
    "+1",
    "+44",
    "+49",
    "+33",
    "+34",
    "+61",
    "+31",
    "+46",
    "+55",
    "+91"
  ]);
  const a = randInt(200, 999);
  const b = randInt(2000, 9999);
  return `${cc}${a}${b}`;
}
Deno.serve(async (req)=>{
  if (req.method !== "POST") {
    return new Response("Method not allowed", {
      status: 405
    });
  }
  const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
  if (!SUPABASE_URL) throw new Error("SUPABASE_URL is required");
  // Read the service role credential from the environment.
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!serviceRoleKey) {
    return new Response(JSON.stringify({
      error: "Missing secret env var",
      hint: "Configure SUPABASE_SERVICE_ROLE_KEY for this function."
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
  const supabaseAdmin = createClient(SUPABASE_URL, serviceRoleKey, {
    auth: {
      persistSession: false
    }
  });
  const body = await req.json().catch(()=>({}));
  const count = typeof body?.count === "number" ? Math.max(1, Math.min(100, body.count)) : 20;
  // Deterministic-ish password for testing; you can change this.
  const password = body?.password || "Test1234!";
  const created = [];
  for(let i = 0; i < count; i++){
    const first = pick(NAMES);
    const last = pick(LAST_NAMES);
    const fullName = `${first} ${last}`;
    // Ensure unique profile usernames: append index.
    const profileUsername = `${slugify(first)}_${slugify(last)}_${i}`.slice(0, 32);
    const email = fakeEmail(i, first, last);
    // 1) Create Auth user
    const { data: user, error: userErr } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        display_name: fullName,
        username: profileUsername
      },
      // Optional: set phone if you want phone login
      phone: pick([
        fakePhone(),
        null
      ]),
      phone_confirm: false
    });
    if (userErr || !user?.user) {
      throw new Error(`Failed to create user: ${userErr?.message || "unknown error"}`);
    }
    const authUserId = user.user.id;
    // 2) Insert profile row
    const country = pick(COUNTRIES);
    const nowMs = Date.now();
    const lastSeen = nowMs - randInt(0, 10) * 60 * 60 * 1000 - randInt(0, 59) * 60 * 1000;
    const joinDate = nowMs - randInt(5, 120) * 24 * 60 * 60 * 1000;
    const avatarUrl = `https://api.dicebear.com/9.x/thumbs/svg?seed=${encodeURIComponent(profileUsername)}`;
    const { error: profileErr } = await supabaseAdmin.from("profiles").insert({
      id: authUserId,
      username: profileUsername,
      full_name: fullName,
      email,
      phone: null,
      avatar_url: avatarUrl,
      last_seen: lastSeen,
      cover_url: null,
      bio: pick(bios),
      country,
      avatar_visibility: "EVERYONE",
      cover_visibility: "EVERYONE",
      phone_visibility: "EVERYONE",
      email_visibility: "EVERYONE",
      bio_visibility: "EVERYONE",
      last_seen_visibility: "EVERYONE",
      online_status_visibility: "EVERYONE",
      is_verified: true,
      join_date: joinDate,
      updated_at: new Date().toISOString(),
      country_code: country
    });
    if (profileErr) {
      // If profile insert fails, surface the error.
      throw profileErr;
    }
    created.push({
      email,
      password,
      profileUsername
    });
  }
  return new Response(JSON.stringify({
    created
  }), {
    status: 200,
    headers: {
      "Content-Type": "application/json"
    }
  });
});
