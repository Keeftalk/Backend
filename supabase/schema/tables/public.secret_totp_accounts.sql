-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_totp_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."secret_totp_accounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "service_name" "text" NOT NULL,
    "username" "text" DEFAULT ''::"text",
    "encrypted_secret_key" "text" NOT NULL,
    "issuer" "text" DEFAULT ''::"text",
    "algorithm" "text" DEFAULT 'SHA1'::"text" NOT NULL,
    "digits" integer DEFAULT 6 NOT NULL,
    "period" integer DEFAULT 30 NOT NULL,
    "color_hex" "text" DEFAULT '#7D5CFF'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_totp_accounts" OWNER TO "postgres";

--
