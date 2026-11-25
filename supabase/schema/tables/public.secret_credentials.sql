-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."secret_credentials" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "service_name" "text" NOT NULL,
    "website" "text" DEFAULT ''::"text",
    "username" "text" DEFAULT ''::"text",
    "encrypted_password" "text" NOT NULL,
    "category" "text" DEFAULT 'Personal'::"text" NOT NULL,
    "password_strength" integer DEFAULT 0 NOT NULL,
    "has_two_factor" boolean DEFAULT false NOT NULL,
    "notes" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."secret_credentials" OWNER TO "postgres";

--
