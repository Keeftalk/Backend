-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profile_views; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."profile_views" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "viewer_id" "uuid" NOT NULL,
    "viewed_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "viewer_privacy_level" "text" DEFAULT 'EVERYONE'::"text",
    "viewed_privacy_level" "text" DEFAULT 'EVERYONE'::"text"
);

ALTER TABLE ONLY "public"."profile_views" REPLICA IDENTITY FULL;


ALTER TABLE "public"."profile_views" OWNER TO "postgres";

--
