-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_milestones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."habit_milestones" (
    "user_id" "uuid" NOT NULL,
    "key" "text" NOT NULL,
    "unlocked_at_epoch_day" bigint NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."habit_milestones" OWNER TO "postgres";

--
