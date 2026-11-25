-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: two_factor_otp_challenges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."two_factor_otp_challenges" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "factor_type" "text" NOT NULL,
    "purpose" "text" NOT NULL,
    "otp_hash" "text" NOT NULL,
    "destination_masked" "text",
    "expires_at" timestamp with time zone NOT NULL,
    "attempt_count" integer DEFAULT 0,
    "max_attempts" integer DEFAULT 5,
    "resend_cooldown_until" timestamp with time zone,
    "consumed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "two_factor_otp_challenges_factor_type_check" CHECK (("factor_type" = ANY (ARRAY['totp'::"text", 'email'::"text", 'sms'::"text", 'backup_code'::"text"]))),
    CONSTRAINT "two_factor_otp_challenges_purpose_check" CHECK (("purpose" = ANY (ARRAY['ENROLLMENT'::"text", 'LOGIN'::"text", 'SECURITY_ACTION'::"text"])))
);


ALTER TABLE "public"."two_factor_otp_challenges" OWNER TO "postgres";

--
