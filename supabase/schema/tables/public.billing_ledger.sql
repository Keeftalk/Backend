-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_ledger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."billing_ledger" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "transaction_type" "text" NOT NULL,
    "base_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "maintenance_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "margin_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "total_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "pricing_version_id" "uuid",
    "description" "text",
    "idempotency_key" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_ledger" OWNER TO "postgres";

--
