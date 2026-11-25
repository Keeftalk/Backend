-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_team_member_upgrade(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_team_member_upgrade"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- If the email ends in @keeftalk.com, set as official and upgrade plan
    IF public.is_keeftalk_employee(NEW.email) THEN
        NEW.is_official := TRUE;
        NEW.plan_type := 'OFFICIAL';
        NEW.storage_limit := 109951162777600; -- 100TB
        NEW.is_verified := TRUE; -- Immediate verified badge
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_team_member_upgrade"() OWNER TO "postgres";

--
