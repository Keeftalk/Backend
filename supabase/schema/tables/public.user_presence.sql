-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_presence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_presence" (
    "user_id" "uuid" NOT NULL,
    "last_seen" timestamp with time zone DEFAULT "now"(),
    "is_online" boolean DEFAULT true
);


ALTER TABLE "public"."user_presence" OWNER TO "postgres";

--
