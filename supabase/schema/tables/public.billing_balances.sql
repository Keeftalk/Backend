-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_balances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."billing_balances" (
    "user_id" "uuid" NOT NULL,
    "prepaid_balance" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "low_balance_threshold" numeric(18,6) DEFAULT 2.000000 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_balances" OWNER TO "postgres";

--
