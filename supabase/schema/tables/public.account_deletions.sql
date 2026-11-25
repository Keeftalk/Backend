-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: account_deletions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."account_deletions" (
    "user_id" "text" NOT NULL,
    "requested_at" timestamp with time zone DEFAULT "now"(),
    "retention_until" timestamp with time zone DEFAULT ("now"() + '30 days'::interval),
    "status" "text" DEFAULT 'DELETION_REQUESTED'::"text",
    "cancelled_at" timestamp with time zone
);


ALTER TABLE "public"."account_deletions" OWNER TO "postgres";

--
