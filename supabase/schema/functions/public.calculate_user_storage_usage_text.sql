-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calculate_user_storage_usage("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
    total_usage BIGINT;
BEGIN
    -- Check if user is in a family (Directly from profile)
    SELECT family_id INTO f_id FROM public.profiles WHERE id = target_user_id::uuid;

    IF f_id IS NOT NULL THEN
        -- Shared family usage: sum of all files owned by all family members
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::text IN (SELECT id::text FROM public.profiles WHERE family_id = f_id)
        AND (status = 'ACTIVE' OR status IS NULL);
    ELSE
        -- Personal usage
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::text = target_user_id::text
        AND (status = 'ACTIVE' OR status IS NULL);
    END IF;

    RETURN COALESCE(total_usage, 0);
END;
$$;


ALTER FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") OWNER TO "postgres";

--
