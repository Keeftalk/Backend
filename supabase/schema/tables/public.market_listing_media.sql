-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listing_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_listing_media" (
    "id" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "listing_id" "text" NOT NULL,
    "url" "text" NOT NULL,
    "thumbnail_url" "text",
    "is_video" boolean DEFAULT false NOT NULL,
    "width" integer DEFAULT 1080 NOT NULL,
    "height" integer DEFAULT 1080 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_listing_media" OWNER TO "postgres";

--
