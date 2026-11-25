-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: premium_products_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."premium_products_config" (
    "product_id" "text" NOT NULL,
    "product_type" "text" DEFAULT 'UNIVERSAL_PREMIUM'::"text" NOT NULL,
    "display_name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "price" numeric(12,2) DEFAULT 9.99 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "billing_period" "text" DEFAULT 'MONTHLY'::"text" NOT NULL,
    "storage_limit_bytes" bigint DEFAULT '536870912000'::bigint NOT NULL,
    "max_members" integer DEFAULT 1 NOT NULL,
    "capabilities" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."premium_products_config" OWNER TO "postgres";

--
