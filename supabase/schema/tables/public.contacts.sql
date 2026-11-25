-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."contacts" (
    "id" "text" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "username" "text",
    "phone" "text",
    "email" "text",
    "avatar_url" "text",
    "secondary_phone" "text",
    "secondary_phone_label" "text",
    "tertiary_phone" "text",
    "tertiary_phone_label" "text",
    "birthday" bigint,
    "calling_card" "text",
    "is_keeftalk_user" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer
);

ALTER TABLE ONLY "public"."contacts" REPLICA IDENTITY FULL;


ALTER TABLE "public"."contacts" OWNER TO "postgres";

--
