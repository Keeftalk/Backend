-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_spam_reporters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."caller_spam_reporters" (
    "user_id" "uuid" NOT NULL,
    "phone_hash" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_spam_reporters" OWNER TO "postgres";

--
