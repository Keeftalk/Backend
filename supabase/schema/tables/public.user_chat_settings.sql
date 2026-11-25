-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_chat_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_chat_settings" (
    "user_id" "uuid" NOT NULL,
    "theme" "text" DEFAULT 'SYSTEM'::"text",
    "wallpaper_type" "text" DEFAULT 'COLOR'::"text",
    "wallpaper_reference" "text" DEFAULT '#F0F2F5'::"text",
    "bubble_style" "text" DEFAULT 'MODERN'::"text",
    "bubble_radius" integer DEFAULT 16,
    "chat_density" "text" DEFAULT 'COMFORTABLE'::"text",
    "animations_enabled" boolean DEFAULT true,
    "emoji_size" integer DEFAULT 24,
    "font_size" integer DEFAULT 16,
    "font_scale" double precision DEFAULT 1.0,
    "bold_text" boolean DEFAULT false,
    "high_contrast" boolean DEFAULT false,
    "reduced_motion" boolean DEFAULT false,
    "link_preview_size" "text" DEFAULT 'NORMAL'::"text",
    "auto_download_mobile" "jsonb" DEFAULT '["PHOTO"]'::"jsonb",
    "auto_download_wifi" "jsonb" DEFAULT '["PHOTO", "VIDEO", "AUDIO", "DOCUMENT"]'::"jsonb",
    "auto_download_roaming" "jsonb" DEFAULT '[]'::"jsonb",
    "upload_photo_quality" "text" DEFAULT 'HIGH'::"text",
    "upload_video_quality" "text" DEFAULT 'STANDARD'::"text",
    "autoplay_gifs" boolean DEFAULT true,
    "autoplay_videos" boolean DEFAULT true,
    "autoplay_voice_notes" boolean DEFAULT true,
    "save_to_gallery" boolean DEFAULT false,
    "enter_key_behavior" "text" DEFAULT 'SEND'::"text",
    "swipe_left_action" "text" DEFAULT 'ARCHIVE'::"text",
    "swipe_right_action" "text" DEFAULT 'REPLY'::"text",
    "double_tap_action" "text" DEFAULT 'REACT'::"text",
    "default_reaction" "text" DEFAULT '??'::"text",
    "link_previews_enabled" boolean DEFAULT true,
    "auto_translate_mode" "text" DEFAULT 'DISABLED'::"text",
    "auto_translate_language" "text" DEFAULT 'en'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_chat_settings" OWNER TO "postgres";

--
