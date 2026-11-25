-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."notes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "title" "text" DEFAULT 'Untitled'::"text",
    "content" "text" DEFAULT ''::"text",
    "color" "text" DEFAULT '#6C63FF'::"text",
    "pinned" boolean DEFAULT false,
    "archived" boolean DEFAULT false,
    "container" "text" DEFAULT 'All'::"text",
    "can_others_add" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer DEFAULT 0
);

ALTER TABLE ONLY "public"."notes" REPLICA IDENTITY FULL;


ALTER TABLE "public"."notes" OWNER TO "postgres";

--
