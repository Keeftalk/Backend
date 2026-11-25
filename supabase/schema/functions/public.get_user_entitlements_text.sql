-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_user_entitlements("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_user_entitlements"("p_user_id" "text") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id uuid;
    v_sub record;
BEGIN
    v_user_id := p_user_id::uuid;
    SELECT plan, storage_limit_gb, hd_upload_enabled, priority_features_enabled, max_file_size_mb
    INTO v_sub
    FROM public.user_subscriptions
    WHERE user_id = v_user_id;
    IF NOT FOUND THEN
        RETURN json_build_object('plan', 'free', 'storage_limit_gb', 1);
    END IF;
    RETURN json_build_object('plan', v_sub.plan, 'storage_limit_gb', v_sub.storage_limit_gb);
END;
$$;


ALTER FUNCTION "public"."get_user_entitlements"("p_user_id" "text") OWNER TO "postgres";

--
