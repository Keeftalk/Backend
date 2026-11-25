-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_profile_storage_usage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_profile_storage_usage"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_id TEXT;
    f_id UUID;
BEGIN
    target_id := COALESCE(NEW.owner_id, OLD.owner_id);

    -- Find if this user is in a family (Directly from profile)
    SELECT family_id INTO f_id FROM public.profiles WHERE id::text = target_id::text;

    IF f_id IS NOT NULL THEN
        -- Update all members of the family to keep their 'storage_used' in sync for the UI
        UPDATE public.profiles
        SET storage_used = public.calculate_user_storage_usage(target_id)
        WHERE family_id = f_id;
    ELSE
        -- Update only the user
        UPDATE public.profiles
        SET storage_used = public.calculate_user_storage_usage(target_id)
        WHERE id::text = target_id::text;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_profile_storage_usage"() OWNER TO "postgres";

--
