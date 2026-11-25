-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_controls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_controls" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "supervisor_id" "uuid" NOT NULL,
    "communication_restriction" "jsonb" DEFAULT '{"groups": "EVERYONE", "calling": "EVERYONE", "messaging": "EVERYONE"}'::"jsonb",
    "content_restriction" "jsonb" DEFAULT '{"link_previews": true, "media_download": "ALWAYS", "sensitive_content": "ALLOW"}'::"jsonb",
    "usage_limit" "jsonb" DEFAULT '{"quiet_hours_end": "07:00", "quiet_hours_start": "22:00", "daily_limit_minutes": 0}'::"jsonb",
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."user_controls" OWNER TO "postgres";

--
