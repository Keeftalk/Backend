-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."book_progress" (
    "book_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "percentage" double precision DEFAULT 0,
    "pdf_page" integer,
    "epub_cfi" "text",
    "reader_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "last_opened_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "read_pages" "text"
);


ALTER TABLE "public"."book_progress" OWNER TO "postgres";

--
