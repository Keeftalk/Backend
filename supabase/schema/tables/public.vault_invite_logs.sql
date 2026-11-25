-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_invite_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."vault_invite_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invite_id" "uuid",
    "action" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "vault_invite_logs_action_check" CHECK (("action" = ANY (ARRAY['VIEW'::"text", 'DOWNLOAD'::"text", 'IMPORT'::"text"])))
);


ALTER TABLE "public"."vault_invite_logs" OWNER TO "postgres";

--
