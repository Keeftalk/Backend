-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_visibility; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."message_visibility" (
    "message_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "is_hidden" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_blurred" boolean DEFAULT false,
    "is_locked" boolean DEFAULT false,
    "updated_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."message_visibility" REPLICA IDENTITY FULL;


ALTER TABLE "public"."message_visibility" OWNER TO "postgres";

--
