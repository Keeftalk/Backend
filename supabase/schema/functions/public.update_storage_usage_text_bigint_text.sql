-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_storage_usage("text", bigint, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := p_user_id::uuid;
    INSERT INTO public.user_storage (user_id, total_size_bytes) VALUES (v_user_id, 0) ON CONFLICT (user_id) DO NOTHING;
    UPDATE public.user_storage
    SET total_size_bytes = total_size_bytes + p_file_size,
        image_size_bytes = CASE WHEN p_file_type LIKE 'image/%' THEN image_size_bytes + p_file_size ELSE image_size_bytes END,
        video_size_bytes = CASE WHEN p_file_type LIKE 'video/%' THEN video_size_bytes + p_file_size ELSE video_size_bytes END,
        document_size_bytes = CASE WHEN p_file_type NOT LIKE 'image/%' AND p_file_type NOT LIKE 'video/%' THEN document_size_bytes + p_file_size ELSE document_size_bytes END,
        updated_at = now()
    WHERE user_id = v_user_id;
END;
$$;


ALTER FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") OWNER TO "postgres";

--
