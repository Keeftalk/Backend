-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_docs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_docs" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "author_or_source" "text" DEFAULT ''::"text" NOT NULL,
    "total_pages_or_sections" integer DEFAULT 1 NOT NULL,
    "format" "text" DEFAULT 'PDF'::"text" NOT NULL,
    "file_size" bigint DEFAULT 0 NOT NULL,
    "mime_type" "text" DEFAULT ''::"text" NOT NULL,
    "cover_url" "text",
    "custom_cover_json" "text",
    "percent_progress" integer DEFAULT 0 NOT NULL,
    "last_read_page" integer DEFAULT 1 NOT NULL,
    "last_read_position_json" "text",
    "is_favorite" boolean DEFAULT false NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "content_hash" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_docs" OWNER TO "postgres";

--
