-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_book_settings" (
    "user_id" "uuid" NOT NULL,
    "show_read_marker" boolean DEFAULT true NOT NULL,
    "button_size_px" integer DEFAULT 38 NOT NULL,
    "green_opacity_percent" integer DEFAULT 50 NOT NULL,
    "read_marker_color_hex" "text" DEFAULT '#2ECC71'::"text" NOT NULL,
    "theme" "text" DEFAULT 'original'::"text" NOT NULL,
    "page_margins_enabled" boolean DEFAULT true NOT NULL,
    "keep_screen_on" boolean DEFAULT true NOT NULL,
    "auto_next_page_on_read" boolean DEFAULT true NOT NULL,
    "volume_keys_turn_page" boolean DEFAULT false NOT NULL,
    "sync_across_devices" boolean DEFAULT true NOT NULL,
    "daily_goal_minutes" integer DEFAULT 30 NOT NULL,
    "yearly_goal_books" integer DEFAULT 24 NOT NULL,
    "pdf_dpi_option" "text" DEFAULT 'lowest'::"text" NOT NULL,
    "pdf_custom_dpi" integer DEFAULT 200 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_settings" OWNER TO "postgres";

--
