-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."secret_settings" (
    "user_id" "uuid" NOT NULL,
    "auto_lock_minutes" integer DEFAULT 5 NOT NULL,
    "block_screenshots" boolean DEFAULT true NOT NULL,
    "clear_clipboard_seconds" integer DEFAULT 30 NOT NULL,
    "wipe_after_failed_tries" boolean DEFAULT true NOT NULL,
    "encrypted_backup_enabled" boolean DEFAULT false NOT NULL,
    "biometric_required" boolean DEFAULT true NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_settings" OWNER TO "postgres";

--
