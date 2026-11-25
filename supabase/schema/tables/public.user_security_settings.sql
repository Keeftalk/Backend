-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_security_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_security_settings" (
    "user_id" "uuid" NOT NULL,
    "two_factor_enabled" boolean DEFAULT false,
    "pin_hash" "text",
    "recovery_email" "text",
    "recovery_email_verified" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "app_lock_enabled" boolean DEFAULT false,
    "app_lock_timeout_seconds" integer DEFAULT 0,
    "biometric_unlock_enabled" boolean DEFAULT false,
    "encrypted_account_key" "text",
    "key_salt" "text",
    "key_nonce" "text",
    "verification_tag" "text",
    "wrapped_aek" "text",
    "wrapped_aek_recovery" "text",
    "recovery_salt" "text",
    "recovery_nonce" "text",
    "preferred_2fa_method" "text"
);

ALTER TABLE ONLY "public"."user_security_settings" REPLICA IDENTITY FULL;


ALTER TABLE "public"."user_security_settings" OWNER TO "postgres";

--
