-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_highlights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_doc_highlights" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "doc_id" "text" NOT NULL,
    "page_or_position" integer NOT NULL,
    "start_offset" integer DEFAULT 0 NOT NULL,
    "end_offset" integer DEFAULT 0 NOT NULL,
    "selected_text" "text" DEFAULT ''::"text" NOT NULL,
    "color_hex" "text" DEFAULT '#2ECC71'::"text" NOT NULL,
    "note_text" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_doc_highlights" OWNER TO "postgres";

--
