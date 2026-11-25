-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."billing_invoices" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invoice_number" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "billing_period_start" timestamp with time zone NOT NULL,
    "billing_period_end" timestamp with time zone NOT NULL,
    "subtotal" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "maintenance_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "margin_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "total" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "status" "text" DEFAULT 'UNPAID'::"text" NOT NULL,
    "due_date" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_invoices" OWNER TO "postgres";

--
