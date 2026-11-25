-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."store_installations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "device_id" "text" DEFAULT 'default_device'::"text" NOT NULL,
    "installed_version" "text" NOT NULL,
    "country_code" "text" DEFAULT 'GLOBAL'::"text" NOT NULL,
    "status" "text" DEFAULT 'INSTALLED'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_installations" OWNER TO "postgres";

--
