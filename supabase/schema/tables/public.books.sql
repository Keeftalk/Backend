-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."books" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "vault_file_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "author" "text",
    "format" "text" NOT NULL,
    "favorite" boolean DEFAULT false,
    "status" "text" DEFAULT 'NOT_STARTED'::"text" NOT NULL,
    "added_at" timestamp with time zone DEFAULT "now"(),
    "last_opened_at" timestamp with time zone DEFAULT "now"(),
    "authors" "text",
    "publisher" "text",
    "description" "text",
    "language" "text",
    "isbn" "text",
    "publish_date" "text",
    "subjects" "text",
    "format_version" "text",
    "page_count" integer,
    "last_read_at" timestamp with time zone,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "total_reading_time_ms" bigint DEFAULT 0,
    "is_deleted" boolean DEFAULT false,
    "goal_end_date" timestamp with time zone,
    "content_hash" "text",
    CONSTRAINT "books_format_check" CHECK (("format" = ANY (ARRAY['PDF'::"text", 'EPUB'::"text"]))),
    CONSTRAINT "books_status_check" CHECK (("status" = ANY (ARRAY['NOT_STARTED'::"text", 'READING'::"text", 'FINISHED'::"text"])))
);


ALTER TABLE "public"."books" OWNER TO "postgres";

--
