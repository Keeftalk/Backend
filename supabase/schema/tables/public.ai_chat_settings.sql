-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_chat_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."ai_chat_settings" (
    "chat_id" "text" NOT NULL,
    "user_id" "uuid",
    "provider_id" "text",
    "model_id" "text",
    "encrypted_system_prompt" "text",
    "prompt_iv" "text",
    "settings_json" "text" NOT NULL,
    "updated_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_chat_settings" OWNER TO "postgres";

--
