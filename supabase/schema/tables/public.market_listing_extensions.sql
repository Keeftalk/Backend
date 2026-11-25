-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listing_extensions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_listing_extensions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "text",
    "buyer_id" "text",
    "extended_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_listing_extensions" OWNER TO "postgres";

--
