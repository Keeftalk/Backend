-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_app_customization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_app_customization" (
    "user_id" "uuid" NOT NULL,
    "enabled_modules" "text"[] DEFAULT '{CHATS,CALLS,SMS,AGENDA,NOTES,EMAIL,VAULT}'::"text"[] NOT NULL,
    "bottom_nav_tabs" "text"[] DEFAULT '{CHATS,CALLS}'::"text"[] NOT NULL,
    "enabled_fab_actions" "text"[] DEFAULT '{NEW_CHAT,NEW_GROUP,QR,AI,ACCESSIBILITY}'::"text"[] NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_enabled" boolean DEFAULT true NOT NULL,
    "sync_enabled" boolean DEFAULT true NOT NULL,
    "fab_size_multiplier" double precision DEFAULT 0.8 NOT NULL,
    "secondary_fab_size_multiplier" double precision DEFAULT 0.8 NOT NULL,
    "chat_spacing_multiplier" double precision DEFAULT 0.5 NOT NULL,
    "onboarding_completed" boolean DEFAULT false
);


ALTER TABLE "public"."user_app_customization" OWNER TO "postgres";

--
