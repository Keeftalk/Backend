-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: can_upload_file("uuid", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_plan TEXT;
    v_usage BIGINT;
    v_limit BIGINT;
BEGIN
    SELECT plan, storage_usage_bytes INTO v_plan, v_usage 
    FROM public.user_subscriptions WHERE user_id = p_user_id;

    -- Define limits in bytes
    v_limit := CASE 
        WHEN v_plan = 'free'     THEN 1024 * 1024 * 1024          -- 1GB
        WHEN v_plan = 'plus'     THEN 10 * 1024 * 1024 * 1024     -- 10GB
        WHEN v_plan = 'pro'      THEN 50 * 1024 * 1024 * 1024     -- 50GB
        WHEN v_plan = 'creator'  THEN 200 * 1024 * 1024 * 1024    -- 200GB
        WHEN v_plan = 'business' THEN 1024 * 1024 * 1024 * 1024   -- 1TB
        ELSE 1024 * 1024 * 1024
    END;

    -- Special Rule: Free users can keep sending media after 1GB, but MUST compress it
    IF v_plan = 'free' AND v_usage >= v_limit THEN
        RETURN jsonb_build_object('allowed', true, 'require_compression', true);
    -- Paid users block when absolutely full
    ELSIF v_usage + p_file_size > v_limit THEN
        RETURN jsonb_build_object('allowed', false, 'reason', 'storage_full');
    -- Normal operation
    ELSE
        RETURN jsonb_build_object('allowed', true, 'require_compression', false);
    END IF;
END;
$$;


ALTER FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) OWNER TO "postgres";

--
