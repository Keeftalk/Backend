-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_releases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."store_releases" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "version" "text" NOT NULL,
    "package_object_key" "text" NOT NULL,
    "package_hash_sha256" "text" NOT NULL,
    "package_size_bytes" bigint DEFAULT 0 NOT NULL,
    "release_notes" "text" DEFAULT ''::"text",
    "min_app_version" "text" DEFAULT '3.0.0'::"text" NOT NULL,
    "signing_key_id" "text" DEFAULT 'official-keeftalk-key-2026'::"text" NOT NULL,
    "status" "text" DEFAULT 'PUBLISHED'::"text" NOT NULL,
    "published_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_releases" OWNER TO "postgres";

--
