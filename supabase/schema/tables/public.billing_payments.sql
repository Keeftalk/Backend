-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."billing_payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "invoice_id" "uuid",
    "amount" numeric(18,6) NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "provider" "text" DEFAULT 'MANUAL'::"text" NOT NULL,
    "provider_transaction_id" "text",
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "idempotency_key" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_payments" OWNER TO "postgres";

--
