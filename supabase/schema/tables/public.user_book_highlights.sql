-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_highlights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_book_highlights" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "page_number" integer NOT NULL,
    "start_offset" integer NOT NULL,
    "end_offset" integer NOT NULL,
    "selected_text" "text" DEFAULT ''::"text" NOT NULL,
    "color_hex" "text" DEFAULT '#2ECC71'::"text" NOT NULL,
    "is_quote" boolean DEFAULT false NOT NULL,
    "note_text" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_highlights" OWNER TO "postgres";

--
