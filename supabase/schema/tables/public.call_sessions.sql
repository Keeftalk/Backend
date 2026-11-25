-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."call_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chat_id" "uuid" NOT NULL,
    "caller_id" "uuid" NOT NULL,
    "receiver_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "state" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "ended_at" timestamp with time zone,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "call_sessions_state_check" CHECK (("state" = ANY (ARRAY['idle'::"text", 'calling'::"text", 'ringing'::"text", 'connected'::"text", 'ended'::"text", 'failed'::"text"]))),
    CONSTRAINT "call_sessions_type_check" CHECK (("type" = ANY (ARRAY['VOICE'::"text", 'VIDEO'::"text"])))
);

ALTER TABLE ONLY "public"."call_sessions" REPLICA IDENTITY FULL;


ALTER TABLE "public"."call_sessions" OWNER TO "postgres";

--
