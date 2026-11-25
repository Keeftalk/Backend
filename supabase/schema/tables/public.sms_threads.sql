-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sms_threads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."sms_threads" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "address" "text",
    "snippet" "text",
    "timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "unread_count" integer DEFAULT 0 NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_muted" boolean DEFAULT false NOT NULL,
    "is_pinned" boolean DEFAULT false NOT NULL,
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sms_threads" OWNER TO "postgres";

--
