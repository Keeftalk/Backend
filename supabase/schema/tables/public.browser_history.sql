-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: browser_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."browser_history" (
    "userId" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "title" "text" NOT NULL,
    "visitTime" bigint NOT NULL,
    "favicon_url" "text"
);


ALTER TABLE "public"."browser_history" OWNER TO "postgres";

--
