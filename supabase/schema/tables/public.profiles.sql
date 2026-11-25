-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "full_name" "text",
    "email" "text",
    "phone" "text",
    "avatar_url" "text",
    "last_seen" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "fcm_token" "text",
    "cover_url" "text",
    "bio" "text",
    "country" "text",
    "avatar_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "cover_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "phone_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "email_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "bio_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "last_seen_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "online_status_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "is_verified" boolean DEFAULT false,
    "join_date" bigint DEFAULT (EXTRACT("epoch" FROM "now"()) * (1000)::numeric),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "country_code" "text",
    "nudges_received" integer DEFAULT 0,
    "views_count" bigint DEFAULT 0,
    "plan_type" "text" DEFAULT 'FREE'::"text",
    "storage_limit" bigint DEFAULT '5368709120'::bigint,
    "storage_used" bigint DEFAULT 0,
    "is_family_owner" boolean DEFAULT false,
    "family_id" "uuid",
    "caller_id_enabled" boolean DEFAULT true NOT NULL,
    "caller_id_contribute" boolean DEFAULT true NOT NULL,
    "phone_hmac" "text",
    "preferred_language" "text" DEFAULT 'en'::"text",
    "is_official" boolean DEFAULT false,
    "use_anonymous_market_identity" boolean DEFAULT false,
    "market_anon_name" "text" DEFAULT ''::"text",
    "market_anon_avatar_url" "text",
    "last_name_change_at" timestamp with time zone,
    "phone_verified" boolean DEFAULT false,
    "total_xp" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "bio_length_check" CHECK (("char_length"("bio") <= 250))
);

ALTER TABLE ONLY "public"."profiles" REPLICA IDENTITY FULL;


ALTER TABLE "public"."profiles" OWNER TO "postgres";

--
