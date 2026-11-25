-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: relationships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."relationships" (
    "user_id" "uuid" NOT NULL,
    "target_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'ACTIVE'::"text",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."relationships" OWNER TO "postgres";

--
