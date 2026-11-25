-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."subscription_metadata" (
    "id" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "price" "text" NOT NULL,
    "storage_limit" bigint NOT NULL,
    "max_file_size" bigint NOT NULL,
    "description" "text",
    "features" "jsonb" DEFAULT '[]'::"jsonb",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."subscription_metadata" OWNER TO "postgres";

--
