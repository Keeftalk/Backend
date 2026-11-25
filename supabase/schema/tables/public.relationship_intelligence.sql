-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: relationship_intelligence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."relationship_intelligence" (
    "user_a" "uuid" NOT NULL,
    "user_b" "uuid" NOT NULL,
    "strength_score" double precision DEFAULT 0.0,
    "last_interaction_at" timestamp with time zone,
    "interaction_count_30d" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."relationship_intelligence" OWNER TO "postgres";

--
