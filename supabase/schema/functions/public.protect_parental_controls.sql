-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: protect_parental_controls(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."protect_parental_controls"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- If a supervisor is set and the current user is NOT that supervisor,
    -- prevent them from changing the parental_controls field.
    IF (OLD.parental_controls->>'supervisor_id' IS NOT NULL
        AND OLD.parental_controls->>'supervisor_id' != (auth.uid())::text) THEN

        -- Silently preserve the OLD parental_controls to prevent RLS/Trigger violations
        -- while allowing other settings to be updated.
        NEW.parental_controls = OLD.parental_controls;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."protect_parental_controls"() OWNER TO "postgres";

--
