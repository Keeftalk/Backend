-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: recovery_seeds; Type: TABLE; Schema: security_private; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "security_private"."recovery_seeds" (
    "user_id" "uuid" NOT NULL,
    "recovery_seed" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "security_private"."recovery_seeds" OWNER TO "postgres";

--
