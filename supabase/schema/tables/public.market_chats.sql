-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "text",
    "buyer_id" "uuid",
    "seller_id" "uuid",
    "as_identity" "text" DEFAULT 'alias'::"text" NOT NULL,
    "start_ts" bigint DEFAULT 0 NOT NULL,
    "status" "text",
    "messages" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "review_state" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_chats" OWNER TO "postgres";

--
