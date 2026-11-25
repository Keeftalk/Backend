-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_nicknames; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."caller_nicknames" (
    "phone_hash" "text" NOT NULL,
    "nickname" "text" NOT NULL,
    "confidence" real DEFAULT 0.0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_nicknames" OWNER TO "postgres";

--
