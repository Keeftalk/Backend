-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."habits" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "color" "text",
    "icon" "text",
    "recurrence_rule" "text" NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_active" boolean DEFAULT true,
    "category" "text" DEFAULT 'drink'::"text" NOT NULL,
    "base_days" integer DEFAULT 18 NOT NULL,
    "created_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "reminder_time_minutes" integer,
    "slot" "text" DEFAULT 'Morning'::"text" NOT NULL,
    "habit_type" "text" DEFAULT 'AUTO'::"text" NOT NULL,
    "amount" integer,
    "unit" "text",
    "color_hex" "text" DEFAULT '#00CCCC'::"text" NOT NULL,
    "is_reading_habit" boolean DEFAULT false NOT NULL,
    "auto_count_reading" boolean DEFAULT true NOT NULL,
    "linked_book_ids" "text" DEFAULT ''::"text" NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."habits" OWNER TO "postgres";

--
