-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_set_preferred_2fa_method("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_exists BOOLEAN;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT EXISTS(
        SELECT 1 FROM public.user_2fa_factors
        WHERE user_id = v_user_id AND factor_type = p_factor_type AND status = 'ACTIVE'
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN jsonb_build_object('success', false, 'message', 'Specified factor is not active.');
    END IF;

    UPDATE public.user_2fa_factors
    SET is_preferred = (factor_type = p_factor_type)
    WHERE user_id = v_user_id;

    UPDATE public.user_security_settings
    SET preferred_2fa_method = p_factor_type
    WHERE user_id = v_user_id;

    RETURN jsonb_build_object('success', true, 'preferred_method', p_factor_type);
END;
$$;


ALTER FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") OWNER TO "postgres";

--
