-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: data_exports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."data_exports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "file_path" "text" NOT NULL,
    "encryption_key_hash" "text",
    "status" "text" DEFAULT 'COMPLETED'::"text",
    "expires_at" timestamp with time zone DEFAULT ("now"() + '14 days'::interval),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."data_exports" OWNER TO "postgres";

--
