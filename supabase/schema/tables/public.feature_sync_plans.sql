-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: feature_sync_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."feature_sync_plans" (
    "id" "text" NOT NULL,
    "feature_id" "text",
    "display_name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "price" numeric(12,2) DEFAULT 0.99 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "billing_period" "text" DEFAULT 'MONTHLY'::"text" NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."feature_sync_plans" OWNER TO "postgres";

--
