-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: can_upload_file("text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
DECLARE
    v_user_id uuid;
    v_limit_gb numeric;
    v_current_bytes bigint;
    v_limit_bytes bigint;
BEGIN
    v_user_id := p_user_id::uuid;
    SELECT storage_limit_gb INTO v_limit_gb FROM public.user_subscriptions WHERE user_id = v_user_id;
    IF v_limit_gb IS NULL THEN v_limit_gb := 1; END IF;
    SELECT total_size_bytes INTO v_current_bytes FROM public.user_storage WHERE user_id = v_user_id;
    IF v_current_bytes IS NULL THEN v_current_bytes := 0; END IF;
    v_limit_bytes := v_limit_gb * 1024 * 1024 * 1024;
    IF (v_current_bytes + p_file_size > v_limit_bytes) THEN
        RETURN json_build_object('allowed', false, 'reason', 'storage_limit_exceeded');
    ELSE
        RETURN json_build_object('allowed', true);
    END IF;
END;
$$;


ALTER FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) OWNER TO "postgres";

--
