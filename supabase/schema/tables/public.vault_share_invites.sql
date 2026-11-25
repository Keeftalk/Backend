-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."vault_share_invites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "item_type" "text" NOT NULL,
    "token_hash" "text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone NOT NULL,
    "revoked_at" timestamp with time zone,
    "max_uses" integer DEFAULT 1,
    "use_count" integer DEFAULT 0,
    "wrapped_fek" "jsonb",
    "max_downloads" integer DEFAULT 100,
    "max_views" integer DEFAULT 1000,
    "total_downloads" integer DEFAULT 0,
    "total_views" integer DEFAULT 0,
    "is_multi" boolean DEFAULT false,
    CONSTRAINT "vault_share_invites_item_type_check" CHECK (("item_type" = ANY (ARRAY['FILE'::"text", 'FOLDER'::"text", 'MULTI'::"text"])))
);


ALTER TABLE "public"."vault_share_invites" OWNER TO "postgres";

--
