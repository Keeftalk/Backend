-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_bookmarks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_book_bookmarks" (
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "page_number" integer NOT NULL,
    "chapter_title" "text" DEFAULT ''::"text" NOT NULL,
    "excerpt" "text" DEFAULT ''::"text" NOT NULL,
    "is_user" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_bookmarks" OWNER TO "postgres";

--
