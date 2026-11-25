-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_book_progress" (
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "page_number" integer NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "phrase_dock_index" integer,
    "free_x" real,
    "free_y" real,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_progress" OWNER TO "postgres";

--
