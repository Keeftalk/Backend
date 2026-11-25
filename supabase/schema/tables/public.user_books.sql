-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_books" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "author" "text" DEFAULT ''::"text" NOT NULL,
    "total_pages" integer DEFAULT 1 NOT NULL,
    "format" "text" DEFAULT 'PDF'::"text" NOT NULL,
    "cover_url" "text",
    "custom_cover_json" "text",
    "percent_progress" integer DEFAULT 0 NOT NULL,
    "last_read_page" integer DEFAULT 1 NOT NULL,
    "hours_read" real DEFAULT 0 NOT NULL,
    "pages_per_day" integer DEFAULT 10 NOT NULL,
    "speed_pages_per_hour" integer DEFAULT 30 NOT NULL,
    "insight_text" "text" DEFAULT ''::"text" NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "is_favorite" boolean DEFAULT false NOT NULL,
    "marked_done" boolean DEFAULT false NOT NULL,
    "original_progress" integer DEFAULT 0 NOT NULL,
    "original_insight" "text" DEFAULT ''::"text" NOT NULL,
    "finished_at" timestamp with time zone,
    "content_hash" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_books" OWNER TO "postgres";

--
