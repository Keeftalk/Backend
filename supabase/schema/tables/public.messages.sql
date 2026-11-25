-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chat_id" "uuid",
    "sender_id" "uuid" NOT NULL,
    "content" "text",
    "type" "text" DEFAULT 'TEXT'::"text" NOT NULL,
    "timestamp" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "status" "text" DEFAULT 'SENT'::"text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "source_language" "text",
    "reply_to_id" "uuid",
    "conversation_id" "text",
    "reply_to_message_id" "uuid",
    "reply_to_text" "text",
    "reply_to_sender" "text",
    "media_locked" boolean DEFAULT false,
    "media_lock_updated_at" bigint,
    "media_lock_updated_by" "uuid",
    "ciphertext" "text",
    "crypto_version" integer DEFAULT 0,
    "envelope_type" integer DEFAULT 0,
    "height" bigint,
    "width" bigint,
    "nonce" "text",
    "is_ai_response" boolean DEFAULT false,
    "edited_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "media_blurred" boolean DEFAULT false,
    "is_deleted_me" boolean DEFAULT false,
    "message_attachment" "text",
    "message_link_previews" "text",
    "message_reactions" "text",
    "message_visibility" "text",
    CONSTRAINT "messages_status_check" CHECK (("status" = ANY (ARRAY['SENT'::"text", 'DELIVERED'::"text", 'FCM_RECEIVED'::"text", 'SEEN'::"text", 'FAILED'::"text"]))),
    CONSTRAINT "messages_type_check" CHECK (("type" = ANY (ARRAY['TEXT'::"text", 'IMAGE'::"text", 'VIDEO'::"text", 'VOICE'::"text", 'FILE'::"text", 'PDF'::"text", 'LOCATION'::"text", 'CONTACT'::"text", 'POLL'::"text", 'CALL_LOG'::"text", 'SHARED_NOTE'::"text", 'SHARED_EMAIL'::"text", 'SHARED_VAULT_FILE'::"text", 'SHARED_AGENDA'::"text", 'REACTION'::"text"])))
);

ALTER TABLE ONLY "public"."messages" REPLICA IDENTITY FULL;


ALTER TABLE "public"."messages" OWNER TO "postgres";

--
