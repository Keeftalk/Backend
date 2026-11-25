-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_bundles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_bundles" (
    "user_id" "uuid" NOT NULL,
    "identity_key" "text" NOT NULL,
    "signed_pre_key" "text" NOT NULL,
    "registration_id" integer NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_bundles" OWNER TO "postgres";

--
