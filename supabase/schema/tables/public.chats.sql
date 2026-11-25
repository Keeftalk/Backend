-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text",
    "type" "text" DEFAULT 'ONE_TO_ONE'::"text" NOT NULL,
    "created_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "last_message_text" "text",
    "last_message_time_ms" bigint,
    "avatar_url" "text",
    "auto_delete_timer" bigint,
    "container_id" "uuid",
    "last_message_id" "uuid",
    "last_message_time" timestamp with time zone,
    "last_activity_at" timestamp with time zone DEFAULT "now"(),
    "auto_translate_enabled" boolean DEFAULT false,
    "last_message_status" "text",
    "last_message_sender_id" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "quick_reaction" "text" DEFAULT 'VOICE'::"text"
);

ALTER TABLE ONLY "public"."chats" REPLICA IDENTITY FULL;


ALTER TABLE "public"."chats" OWNER TO "postgres";

--
