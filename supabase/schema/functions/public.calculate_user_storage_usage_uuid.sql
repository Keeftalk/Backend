-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calculate_user_storage_usage("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
    total_usage BIGINT;
BEGIN
    SELECT family_id INTO f_id FROM public.profiles WHERE id = target_user_id;

    IF f_id IS NOT NULL THEN
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::uuid IN (SELECT id FROM public.profiles WHERE family_id = f_id)
        AND (status != 'DELETED' OR status IS NULL);
    ELSE
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::uuid = target_user_id
        AND (status != 'DELETED' OR status IS NULL);
    END IF;

    RETURN COALESCE(total_usage, 0);
END;
$$;


ALTER FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") OWNER TO "postgres";

--
