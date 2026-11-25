-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_sellers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_sellers" (
    "id" "uuid" NOT NULL,
    "alias" "text" DEFAULT ''::"text" NOT NULL,
    "real_name" "text" DEFAULT ''::"text" NOT NULL,
    "since_year" integer DEFAULT EXTRACT("year" FROM CURRENT_DATE) NOT NULL,
    "verified" integer DEFAULT 0 NOT NULL,
    "reviews" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_sellers" OWNER TO "postgres";

--
