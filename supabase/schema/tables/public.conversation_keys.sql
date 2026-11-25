-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: conversation_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."conversation_keys" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "conversation_id" "text" NOT NULL,
    "encrypted_key" "text" NOT NULL,
    "nonce" "text" NOT NULL,
    "version" integer DEFAULT 1,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "epoch" integer DEFAULT 1
);


ALTER TABLE "public"."conversation_keys" OWNER TO "postgres";

--
