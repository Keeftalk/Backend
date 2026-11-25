-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_identities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."caller_identities" (
    "phone_hash" "text" NOT NULL,
    "first_name" "text",
    "family_name" "text",
    "first_name_confidence" real DEFAULT 0.0 NOT NULL,
    "family_name_confidence" real DEFAULT 0.0 NOT NULL,
    "is_verified_profile" boolean DEFAULT false NOT NULL,
    "verified_first_name" "text",
    "verified_family_name" "text",
    "business_name" "text",
    "business_confidence" real DEFAULT 0.0 NOT NULL,
    "spam_score" real DEFAULT 0.0 NOT NULL,
    "last_updated" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_identities" OWNER TO "postgres";

--
