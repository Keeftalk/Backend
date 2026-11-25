-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calendar_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."calendar_items" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "color" "text",
    "icon" "text",
    "location" "text",
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "is_all_day" boolean DEFAULT false,
    "timezone" "text",
    "recurrence_rule" "text",
    "priority" "text" DEFAULT 'MEDIUM'::"text",
    "status" "text" DEFAULT 'PENDING'::"text",
    "is_private" boolean DEFAULT false,
    "owner_id" "uuid" NOT NULL,
    "category_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "meeting_type" "text",
    "meeting_link" "text",
    "progress" integer DEFAULT 0,
    "pomodoro_count" integer DEFAULT 0,
    "deadline" timestamp with time zone,
    "parent_item_id" "uuid",
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer DEFAULT 0
);


ALTER TABLE "public"."calendar_items" OWNER TO "postgres";

--
