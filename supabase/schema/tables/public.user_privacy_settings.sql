-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_privacy_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_privacy_settings" (
    "user_id" "uuid" NOT NULL,
    "profile_photo_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "about_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "last_seen_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "read_receipts_enabled" boolean DEFAULT true,
    "typing_indicators_enabled" boolean DEFAULT true,
    "profile_view_history_enabled" boolean DEFAULT false,
    "call_permission" "text" DEFAULT 'EVERYONE'::"text",
    "group_permission" "text" DEFAULT 'EVERYONE'::"text",
    "screenshot_protection_enabled" boolean DEFAULT false,
    "biometric_lock_enabled" boolean DEFAULT false,
    "biometric_timeout_minutes" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "connections_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "call_retention_days" integer DEFAULT 30,
    "note_lock_timeout" integer DEFAULT 0,
    "vault_auto_lock_timeout" integer DEFAULT 0,
    "email_auth_required" boolean DEFAULT false,
    "screenshot_protection_vault" boolean DEFAULT false,
    CONSTRAINT "user_privacy_settings_about_visibility_check" CHECK (("about_visibility" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_call_permission_check" CHECK (("call_permission" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_group_permission_check" CHECK (("group_permission" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_last_seen_visibility_check" CHECK (("last_seen_visibility" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_profile_photo_visibility_check" CHECK (("profile_photo_visibility" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"])))
);

ALTER TABLE ONLY "public"."user_privacy_settings" REPLICA IDENTITY FULL;


ALTER TABLE "public"."user_privacy_settings" OWNER TO "postgres";

--
