-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."vault_shares" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "wrapped_fek" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone NOT NULL,
    "is_revoked" boolean DEFAULT false,
    "max_downloads" integer DEFAULT 10,
    "download_count" integer DEFAULT 0
);


ALTER TABLE "public"."vault_shares" OWNER TO "postgres";

--
