-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_family_member_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_family_member_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_count INT;
    max_allowed INT;
BEGIN
    SELECT COUNT(*) INTO current_count FROM public.family_members WHERE family_id = NEW.family_id AND status = 'ACTIVE';
    SELECT max_total_users INTO max_allowed FROM public.family_groups WHERE id = NEW.family_id;

    IF current_count >= COALESCE(max_allowed, 6) THEN
        RAISE EXCEPTION 'Family member limit reached (Maximum % total members allowed).', COALESCE(max_allowed, 6);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_family_member_limit"() OWNER TO "postgres";

--
