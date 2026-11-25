-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_storage_regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_storage_regions" (
    "user_id" "uuid" NOT NULL,
    "country_code" character varying(2) NOT NULL,
    "storage_region" character varying(10) NOT NULL,
    "private_bucket" "text" NOT NULL,
    "public_bucket" "text" NOT NULL,
    "market_bucket" "text" NOT NULL,
    "detention_bucket" "text" NOT NULL,
    "backups_bucket" "text" NOT NULL,
    "assigned_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "assignment_version" integer DEFAULT 1 NOT NULL
);


ALTER TABLE "public"."user_storage_regions" OWNER TO "postgres";

--
