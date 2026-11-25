-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_broadcast_sync; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_broadcast_sync" (
    "user_id" "uuid" NOT NULL,
    "last_synced_broadcast_id" "uuid",
    "last_synced_language" "text",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_broadcast_sync" OWNER TO "postgres";

--
