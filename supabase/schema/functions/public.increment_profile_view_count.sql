-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: increment_profile_view_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."increment_profile_view_count"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Increment the views_count for the user being viewed
    -- NEW.viewed_id refers to the ID in the profile_views table
    UPDATE public.profiles
    SET views_count = views_count + 1
    WHERE id::text = NEW.viewed_id::text;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_profile_view_count"() OWNER TO "postgres";

--
