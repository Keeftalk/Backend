-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_family_member_removal(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_family_member_removal"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF OLD.role = 'member' AND CURRENT_TIMESTAMP < OLD.eligible_for_removal_at THEN
        RAISE EXCEPTION 'Family members cannot be removed until 1 year has passed since being added (Eligible for removal after %).', OLD.eligible_for_removal_at;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."check_family_member_removal"() OWNER TO "postgres";

--
