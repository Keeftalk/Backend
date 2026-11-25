-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: browser_bookmarks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."browser_bookmarks" (
    "userId" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "title" "text" NOT NULL,
    "folder" "text" DEFAULT 'Default'::"text",
    "parent_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "last_modified" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "is_folder" boolean DEFAULT false,
    "position" integer DEFAULT 0,
    "is_deleted" boolean DEFAULT false
);


ALTER TABLE "public"."browser_bookmarks" OWNER TO "postgres";

--
