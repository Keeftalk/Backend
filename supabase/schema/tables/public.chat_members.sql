-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."chat_members" (
    "chat_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "joined_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "is_pinned" boolean DEFAULT false,
    "is_muted" boolean DEFAULT false,
    "is_archived" boolean DEFAULT false,
    "role" "text" DEFAULT 'member'::"text",
    "notification_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "theme_id" "text",
    "last_read_message_id" "uuid",
    "last_delivered_message_id" "uuid",
    "last_read_at" timestamp with time zone,
    "last_delivered_at" timestamp with time zone,
    "is_favorite" boolean DEFAULT false,
    "nickname" "text",
    "auto_save_photos" boolean DEFAULT false,
    "read_receipts_enabled" boolean DEFAULT true,
    "typing_indicator_enabled" boolean DEFAULT true,
    "quick_reaction" "text"
);

ALTER TABLE ONLY "public"."chat_members" REPLICA IDENTITY FULL;


ALTER TABLE "public"."chat_members" OWNER TO "postgres";

--
