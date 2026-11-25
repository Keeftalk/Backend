-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: decrement_file_reference("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
    new_count INTEGER;
    current_status TEXT;
    file_owner TEXT;
    file_path TEXT;
    category TEXT;
BEGIN
    SELECT status, owner_id::TEXT, storage_path
    INTO current_status, file_owner, file_path
    FROM public.files
    WHERE id = target_file_id;

    IF current_status <> 'ACTIVE' THEN
        RETURN;
    END IF;

    category := split_part(file_path, '/', 2);

    UPDATE public.files
    SET reference_count = reference_count - 1
    WHERE id = target_file_id
    RETURNING reference_count INTO new_count;

    IF new_count <= 0 THEN
        UPDATE public.files
        SET status = 'TRASH',
            archived_at = now(),
            scheduled_purge_at = now() + INTERVAL '30 days',
            original_bucket = 'keeftalk-private',
            original_path = file_path,
            original_category = category
        WHERE id = target_file_id;

        INSERT INTO public.storage_lifecycle_queue (file_id, user_id, action)
        VALUES (target_file_id, file_owner, 'MOVE_TO_TRASH');
    END IF;
END;
$$;


ALTER FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") OWNER TO "postgres";

--
