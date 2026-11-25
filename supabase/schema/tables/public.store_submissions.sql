-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."store_submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "publisher_id" "text" NOT NULL,
    "version" "text" NOT NULL,
    "package_object_key" "text" NOT NULL,
    "status" "text" DEFAULT 'UPLOADED'::"text" NOT NULL,
    "validation_report" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "submitted_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_submissions" OWNER TO "postgres";

--
