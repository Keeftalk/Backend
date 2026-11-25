-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_signaling; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."call_signaling" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "call_id" "uuid" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "call_signaling_type_check" CHECK (("type" = ANY (ARRAY['offer'::"text", 'answer'::"text", 'ice-candidate'::"text", 'hangup'::"text"])))
);

ALTER TABLE ONLY "public"."call_signaling" REPLICA IDENTITY FULL;


ALTER TABLE "public"."call_signaling" OWNER TO "postgres";

--
