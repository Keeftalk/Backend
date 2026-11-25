-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_pricing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."billing_pricing" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version_name" "text" NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "storage_rate_per_gb_month" numeric(18,6) DEFAULT 0.015000 NOT NULL,
    "bandwidth_rate_per_gb" numeric(18,6) DEFAULT 0.020000 NOT NULL,
    "read_op_rate_per_10k" numeric(18,6) DEFAULT 0.003600 NOT NULL,
    "write_op_rate_per_10k" numeric(18,6) DEFAULT 0.045000 NOT NULL,
    "backup_rate_per_gb_month" numeric(18,6) DEFAULT 0.020000 NOT NULL,
    "maintenance_allocation_pct" numeric(6,4) DEFAULT 0.1200 NOT NULL,
    "founder_margin_pct" numeric(6,4) DEFAULT 0.0500 NOT NULL,
    "effective_from" timestamp with time zone DEFAULT "now"() NOT NULL,
    "effective_until" timestamp with time zone,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_pricing" OWNER TO "postgres";

--
