-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: two_factor_login_challenges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."two_factor_login_challenges" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "allowed_factors" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "preferred_factor" "text",
    "verification_token" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone DEFAULT ("now"() + '00:10:00'::interval) NOT NULL,
    "verified_at" timestamp with time zone,
    CONSTRAINT "two_factor_login_challenges_status_check" CHECK (("status" = ANY (ARRAY['PENDING'::"text", 'VERIFIED'::"text", 'EXPIRED'::"text"])))
);


ALTER TABLE "public"."two_factor_login_challenges" OWNER TO "postgres";

--
