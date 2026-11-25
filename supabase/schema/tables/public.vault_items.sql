-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."vault_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "file_id" "uuid" NOT NULL,
    "folder_id" "uuid",
    "title" "text" DEFAULT '[Encrypted]'::"text",
    "favorite" boolean DEFAULT false,
    "locked" boolean DEFAULT false,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "is_deleted" boolean DEFAULT false,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tags" "jsonb" DEFAULT '[]'::"jsonb",
    "is_archived" boolean DEFAULT false NOT NULL,
    "offline_status" "text" DEFAULT 'NONE'::"text",
    "offline_path" "text",
    "last_accessed_at" timestamp with time zone,
    CONSTRAINT "vault_items_offline_status_check" CHECK (("offline_status" = ANY (ARRAY['NONE'::"text", 'QUEUED'::"text", 'DOWNLOADING'::"text", 'AVAILABLE'::"text", 'FAILED'::"text"])))
);


ALTER TABLE "public"."vault_items" OWNER TO "postgres";

--
