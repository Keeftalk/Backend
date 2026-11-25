-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_id_quotas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."caller_id_quotas" (
    "user_id" "uuid" NOT NULL,
    "daily_lookups" integer DEFAULT 0 NOT NULL,
    "last_lookup_date" "date" DEFAULT CURRENT_DATE,
    "is_suspended" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."caller_id_quotas" OWNER TO "postgres";

--
