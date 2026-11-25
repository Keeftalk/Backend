-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: BIN_DB; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."BIN_DB" (
    "BIN" "text" NOT NULL,
    "Brand" "text",
    "Type" "text",
    "Category" "text",
    "Issuer" "text",
    "IssuerPhone" "text",
    "IssuerUrl" "text",
    "isoCode2" "text",
    "isoCode3" "text",
    "CountryName" "text"
);


ALTER TABLE "public"."BIN_DB" OWNER TO "postgres";

--
