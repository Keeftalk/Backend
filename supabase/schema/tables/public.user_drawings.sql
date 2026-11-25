-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_drawings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_drawings" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "canvas_width" integer DEFAULT 1080 NOT NULL,
    "canvas_height" integer DEFAULT 1920 NOT NULL,
    "background_color" "text" DEFAULT '#FFFFFF'::"text" NOT NULL,
    "format_version" integer DEFAULT 1 NOT NULL,
    "content_json" "text",
    "thumbnail_url" "text",
    "content_hash" "text",
    "revision" bigint DEFAULT 1 NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_drawings" OWNER TO "postgres";

--
