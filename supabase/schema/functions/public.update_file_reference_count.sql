-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_file_reference_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_file_reference_count"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_file_id UUID;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        target_file_id := NEW.file_id;
        UPDATE public.files SET reference_count = reference_count + 1 WHERE id = target_file_id;
    ELSIF (TG_OP = 'DELETE') THEN
        target_file_id := OLD.file_id;
        UPDATE public.files SET reference_count = reference_count - 1 WHERE id = target_file_id;
    END IF;

    UPDATE public.files 
    SET status = CASE WHEN reference_count <= 0 THEN 'PENDING_DELETE' ELSE 'ACTIVE' END,
        deleted_at = CASE WHEN reference_count <= 0 THEN NOW() ELSE NULL END
    WHERE id = target_file_id;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_file_reference_count"() OWNER TO "postgres";

--
