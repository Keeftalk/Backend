-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: usage_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."usage_sessions" (
    "session_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "started_at" bigint NOT NULL,
    "ended_at" bigint NOT NULL,
    "duration_ms" bigint NOT NULL,
    "source" "text" NOT NULL,
    "feature" "text" NOT NULL,
    "created_at" bigint NOT NULL
);


ALTER TABLE "public"."usage_sessions" OWNER TO "postgres";

--
