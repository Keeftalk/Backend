-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."call_logs" (
    "id" "text" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "peer_id" "uuid",
    "peer_number" "text" NOT NULL,
    "peer_name" "text",
    "type" "text" NOT NULL,
    "is_keeftalk" boolean DEFAULT false,
    "call_type" "text",
    "duration" integer DEFAULT 0,
    "timestamp" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer,
    "is_deleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "call_logs_call_type_check" CHECK (("call_type" = ANY (ARRAY['VOICE'::"text", 'VIDEO'::"text", 'GSM'::"text"]))),
    CONSTRAINT "call_logs_type_check" CHECK (("type" = ANY (ARRAY['INCOMING'::"text", 'OUTGOING'::"text", 'MISSED'::"text", 'REJECTED'::"text"])))
);


ALTER TABLE "public"."call_logs" OWNER TO "postgres";

--
