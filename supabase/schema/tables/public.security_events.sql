-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: security_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."security_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "event_type" "text" NOT NULL,
    "description" "text",
    "device_id" "text",
    "ip_address" "text",
    "country" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "city" "text",
    "status" "text" DEFAULT 'SUCCESS'::"text"
);


ALTER TABLE "public"."security_events" OWNER TO "postgres";

--
