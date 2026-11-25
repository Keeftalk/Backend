-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_offers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_offers" (
    "id" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "listing_id" "text" NOT NULL,
    "buyer_id" "uuid" NOT NULL,
    "buyer_name" "text" NOT NULL,
    "offer_amount" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'TND'::"text" NOT NULL,
    "message" "text",
    "counter_amount" numeric(12,2),
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_offers" OWNER TO "postgres";

--
