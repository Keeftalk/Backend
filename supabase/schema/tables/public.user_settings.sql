-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_settings" (
    "user_id" "uuid" NOT NULL,
    "chat_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "call_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "note_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "vault_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "calendar_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "email_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "notification_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "privacy_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "parental_controls" "jsonb" DEFAULT '{}'::"jsonb",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "sms_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "book_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "feed_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "browser_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "habit_settings" "text"
);


ALTER TABLE "public"."user_settings" OWNER TO "postgres";

--
