-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_categories" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "icon_name" "text" DEFAULT 'category'::"text" NOT NULL,
    "subcategories" "jsonb" DEFAULT '[]'::"jsonb"
);


ALTER TABLE "public"."market_categories" OWNER TO "postgres";

--
