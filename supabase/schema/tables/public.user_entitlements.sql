-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_entitlements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_entitlements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "source" "text" NOT NULL,
    "plan" "public"."subscription_plan" DEFAULT 'FREE'::"public"."subscription_plan" NOT NULL,
    "storage_bytes" bigint DEFAULT 0,
    "starts_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone,
    "lifetime" boolean DEFAULT false,
    "source_key_id" "uuid",
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_entitlements_source_check" CHECK (("source" = ANY (ARRAY['subscription'::"text", 'redeemed_key'::"text", 'promotional'::"text", 'administrative'::"text", 'lifetime'::"text", 'other'::"text"]))),
    CONSTRAINT "user_entitlements_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'expired'::"text", 'revoked'::"text"])))
);


ALTER TABLE "public"."user_entitlements" OWNER TO "postgres";

--
