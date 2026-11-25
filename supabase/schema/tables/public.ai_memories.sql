-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_memories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."ai_memories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "encrypted_content" "text" NOT NULL,
    "iv" "text" NOT NULL,
    "scope" "text" NOT NULL,
    "chat_id" "text",
    "category" "text",
    "importance" integer DEFAULT 0,
    "created_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_memories" OWNER TO "postgres";

--
