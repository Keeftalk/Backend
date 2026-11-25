-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: todo_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."todo_tasks" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "notes" "text" DEFAULT ''::"text" NOT NULL,
    "due_date" "text" DEFAULT ''::"text" NOT NULL,
    "priority" integer DEFAULT 1 NOT NULL,
    "list_id" "text",
    "completed" boolean DEFAULT false NOT NULL,
    "created_at" bigint NOT NULL,
    "completed_at" bigint DEFAULT 0 NOT NULL,
    "reminder" "text" DEFAULT ''::"text" NOT NULL,
    "reminder_fired" boolean DEFAULT false NOT NULL,
    "updated_at" bigint NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."todo_tasks" OWNER TO "postgres";

--
