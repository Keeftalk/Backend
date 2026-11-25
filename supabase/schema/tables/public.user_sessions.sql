-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "device_id" "text" NOT NULL,
    "device_name" "text",
    "platform" "text",
    "app_version" "text",
    "ip_address" "text",
    "country" "text",
    "last_active" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_current" boolean DEFAULT false,
    "fcm_token" "text",
    "manufacturer" "text",
    "model" "text",
    "city" "text",
    "auth_method" "text"
);

ALTER TABLE ONLY "public"."user_sessions" REPLICA IDENTITY FULL;


ALTER TABLE "public"."user_sessions" OWNER TO "postgres";

--
