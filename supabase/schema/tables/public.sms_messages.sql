-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sms_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."sms_messages" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "thread_id" "text" NOT NULL,
    "address" "text",
    "body" "text",
    "timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "read" integer DEFAULT 0 NOT NULL,
    "type" integer DEFAULT 1 NOT NULL,
    "status" integer DEFAULT 0 NOT NULL,
    "is_mms" boolean DEFAULT false NOT NULL,
    "attachments_json" "text",
    "delivery_status" integer DEFAULT '-1'::integer NOT NULL,
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sms_messages" OWNER TO "postgres";

--
