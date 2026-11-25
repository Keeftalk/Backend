-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_extensions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."store_extensions" (
    "id" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" DEFAULT 'TOOL'::"text" NOT NULL,
    "publisher_id" "text" NOT NULL,
    "short_description" "text" DEFAULT ''::"text",
    "long_description" "text" DEFAULT ''::"text",
    "category" "text" DEFAULT 'tools'::"text" NOT NULL,
    "age_rating" "text" DEFAULT '4+'::"text" NOT NULL,
    "languages" "text"[] DEFAULT '{English}'::"text"[] NOT NULL,
    "compatible_modules" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "min_app_version" "text" DEFAULT '3.0.0'::"text" NOT NULL,
    "current_version" "text" DEFAULT '1.0.0'::"text" NOT NULL,
    "status" "text" DEFAULT 'DRAFT'::"text" NOT NULL,
    "is_featured" boolean DEFAULT false NOT NULL,
    "download_count" bigint DEFAULT 0 NOT NULL,
    "install_count" bigint DEFAULT 0 NOT NULL,
    "rating_avg" numeric(3,2) DEFAULT 0.00 NOT NULL,
    "rating_count" integer DEFAULT 0 NOT NULL,
    "cover_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "screenshot01" "text",
    "screenshot02" "text",
    "screenshot03" "text",
    "screenshot04" "text",
    "screenshot05" "text",
    "screenshot06" "text",
    "screenshot07" "text"
);


ALTER TABLE "public"."store_extensions" OWNER TO "postgres";

--
