-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_invite_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."vault_share_invite_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invite_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "item_type" "text" NOT NULL,
    "wrapped_fek" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "vault_share_invite_items_item_type_check" CHECK (("item_type" = ANY (ARRAY['FILE'::"text", 'FOLDER'::"text"])))
);


ALTER TABLE "public"."vault_share_invite_items" OWNER TO "postgres";

--
