-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: link_previews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."link_previews" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "url" "text" NOT NULL,
    "normalized_url" "text" NOT NULL,
    "canonical_url" "text",
    "domain" "text",
    "title" "text",
    "description" "text",
    "image_url" "text",
    "favicon_url" "text",
    "site_name" "text",
    "metadata" "jsonb",
    "status" "text" DEFAULT 'SUCCESS'::"text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "expires_at" timestamp with time zone
);


ALTER TABLE "public"."link_previews" OWNER TO "postgres";

--
