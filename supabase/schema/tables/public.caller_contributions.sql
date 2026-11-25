-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_contributions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."caller_contributions" (
    "contributor_user_id" "uuid" NOT NULL,
    "phone_hash" "text" NOT NULL,
    "field_type" "text" NOT NULL,
    "candidate_value" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_contributions" OWNER TO "postgres";

--
