-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: redeem_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."redeem_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "code_id" "uuid",
    "code" "text" NOT NULL,
    "redeemed_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."redeem_history" OWNER TO "postgres";

--
