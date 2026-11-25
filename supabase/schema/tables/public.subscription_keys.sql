-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."subscription_keys" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "key_hash" "text" NOT NULL,
    "key_prefix" "text" NOT NULL,
    "entitlement_type" "text" NOT NULL,
    "plan" "public"."subscription_plan" DEFAULT 'FREE'::"public"."subscription_plan" NOT NULL,
    "storage_bytes" bigint DEFAULT 0,
    "duration_seconds" bigint,
    "lifetime" boolean DEFAULT false,
    "max_redemptions" integer DEFAULT 1,
    "redemption_count" integer DEFAULT 0,
    "valid_from" timestamp with time zone DEFAULT "now"(),
    "valid_until" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "revoked_at" timestamp with time zone,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "subscription_keys_entitlement_type_check" CHECK (("entitlement_type" = ANY (ARRAY['plan'::"text", 'storage'::"text", 'combined'::"text"])))
);


ALTER TABLE "public"."subscription_keys" OWNER TO "postgres";

--
