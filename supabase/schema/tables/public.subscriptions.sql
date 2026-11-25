-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."subscriptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "plan" "public"."subscription_plan" DEFAULT 'FREE'::"public"."subscription_plan" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "purchase_token" "text",
    "order_id" "text",
    "expiry_date" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."subscriptions" OWNER TO "postgres";

--
