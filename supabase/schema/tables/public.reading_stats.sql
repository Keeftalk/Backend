-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: reading_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."reading_stats" (
    "date" "date" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "time_spent_millis" bigint DEFAULT 0,
    "pages_read" integer DEFAULT 0,
    "books_finished" integer DEFAULT 0,
    "sessions_count" integer DEFAULT 0,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."reading_stats" OWNER TO "postgres";

--
