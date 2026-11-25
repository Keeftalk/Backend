-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."files" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "storage_path" "text" NOT NULL,
    "file_hash" "text",
    "file_name" "text",
    "mime_type" "text",
    "file_size" bigint,
    "file_type" "text",
    "source_type" "text" NOT NULL,
    "width" integer,
    "height" integer,
    "duration" integer,
    "thumbnail_path" "text",
    "encryption_metadata" "jsonb",
    "reference_count" integer DEFAULT 0,
    "status" "text" DEFAULT 'ACTIVE'::"text",
    "security_metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    "local_path" "text",
    "thumbnail_remote_path" "text",
    "thumbnail_size" bigint,
    "thumbnail_width" integer,
    "thumbnail_height" integer,
    "thumbnail_hmac" "text",
    "fps" integer,
    "video_codec" "text",
    "audio_codec" "text",
    "bitrate" bigint,
    "sample_rate" integer,
    "channels" integer,
    "pages" integer,
    "extended_metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "physical_size" "text",
    "archived_at" timestamp with time zone,
    "detention_at" timestamp with time zone,
    "scheduled_purge_at" timestamp with time zone,
    "original_bucket" "text",
    "original_path" "text",
    "original_category" "text"
);

ALTER TABLE ONLY "public"."files" REPLICA IDENTITY FULL;


ALTER TABLE "public"."files" OWNER TO "postgres";

--
