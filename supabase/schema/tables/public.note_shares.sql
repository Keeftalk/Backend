-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: note_shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."note_shares" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "note_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "access" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "note_shares_access_check" CHECK (("access" = ANY (ARRAY['read'::"text", 'write'::"text"])))
);

ALTER TABLE ONLY "public"."note_shares" REPLICA IDENTITY FULL;


ALTER TABLE "public"."note_shares" OWNER TO "postgres";

--
