-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_time_tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_time_tracking" (
    "user_id" "uuid" NOT NULL,
    "epoch_day" bigint NOT NULL,
    "feature_key" "text" NOT NULL,
    "duration_seconds" bigint DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_time_tracking" OWNER TO "postgres";

--
