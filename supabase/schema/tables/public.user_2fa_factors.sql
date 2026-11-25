-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_2fa_factors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_2fa_factors" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "factor_type" "text" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "verified_destination" "text",
    "totp_secret" "text",
    "is_preferred" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "last_used_at" timestamp with time zone,
    CONSTRAINT "user_2fa_factors_factor_type_check" CHECK (("factor_type" = ANY (ARRAY['totp'::"text", 'email'::"text", 'sms'::"text"]))),
    CONSTRAINT "user_2fa_factors_status_check" CHECK (("status" = ANY (ARRAY['PENDING'::"text", 'ACTIVE'::"text", 'DISABLED'::"text"])))
);


ALTER TABLE "public"."user_2fa_factors" OWNER TO "postgres";

--
