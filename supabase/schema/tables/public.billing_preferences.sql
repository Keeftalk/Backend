-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_preferences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."billing_preferences" (
    "user_id" "uuid" NOT NULL,
    "payment_mode" "text" DEFAULT 'PREPAID'::"text" NOT NULL,
    "credit_limit" numeric(18,6) DEFAULT 50.000000 NOT NULL,
    "spending_limit" numeric(18,6) DEFAULT 100.000000 NOT NULL,
    "spending_alert_threshold" numeric(18,6) DEFAULT 80.000000 NOT NULL,
    "auto_topup_enabled" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_preferences" OWNER TO "postgres";

--
