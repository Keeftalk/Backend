-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."ai_credentials" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "provider_id" "text" NOT NULL,
    "encrypted_key" "text" NOT NULL,
    "iv" "text" NOT NULL,
    "version" integer NOT NULL,
    "updated_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_credentials" OWNER TO "postgres";

--
