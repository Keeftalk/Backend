-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_media_assets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."store_media_assets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "release_version" "text" NOT NULL,
    "asset_type" "text" NOT NULL,
    "object_key" "text" NOT NULL,
    "display_order" integer DEFAULT 0 NOT NULL,
    "file_size_bytes" bigint DEFAULT 0,
    "hash_sha256" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "store_media_assets_asset_type_check" CHECK (("asset_type" = ANY (ARRAY['COVER'::"text", 'SCREENSHOT'::"text"])))
);


ALTER TABLE "public"."store_media_assets" OWNER TO "postgres";

--
