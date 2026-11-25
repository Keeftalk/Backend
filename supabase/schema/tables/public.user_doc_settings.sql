-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_doc_settings" (
    "user_id" "uuid" NOT NULL,
    "theme" "text" DEFAULT 'original'::"text" NOT NULL,
    "font_size_sp" integer DEFAULT 15 NOT NULL,
    "keep_screen_on" boolean DEFAULT true NOT NULL,
    "show_line_numbers" boolean DEFAULT true NOT NULL,
    "word_wrap" boolean DEFAULT true NOT NULL,
    "sync_across_devices" boolean DEFAULT true NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_doc_settings" OWNER TO "postgres";

--
