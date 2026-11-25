-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_publishers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."store_publishers" (
    "id" "text" NOT NULL,
    "user_id" "uuid",
    "display_name" "text" NOT NULL,
    "description" "text" DEFAULT ''::"text",
    "website" "text",
    "is_verified" boolean DEFAULT false NOT NULL,
    "is_developer_approved" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_publishers" OWNER TO "postgres";

--
