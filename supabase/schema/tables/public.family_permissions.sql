-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: family_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."family_permissions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "family_member_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "level" "text" DEFAULT 'VIEW'::"text" NOT NULL
);


ALTER TABLE "public"."family_permissions" OWNER TO "postgres";

--
