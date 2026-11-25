-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: enforce_name_change_cooldown(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."enforce_name_change_cooldown"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Check if full_name is being updated
    IF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
        IF OLD.last_name_change_at IS NOT NULL AND OLD.last_name_change_at > (now() - INTERVAL '90 days') THEN
            RAISE EXCEPTION 'Name can only be changed once every 90 days. Next available change: %',
                (OLD.last_name_change_at + INTERVAL '90 days');
        END IF;
        NEW.last_name_change_at = now();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_name_change_cooldown"() OWNER TO "postgres";

--
