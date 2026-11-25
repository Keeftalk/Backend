-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_bookmarks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_doc_bookmarks" (
    "user_id" "uuid" NOT NULL,
    "doc_id" "text" NOT NULL,
    "page_or_position" integer NOT NULL,
    "chapter_title" "text" DEFAULT ''::"text" NOT NULL,
    "excerpt" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_doc_bookmarks" OWNER TO "postgres";

--
