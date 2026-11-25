-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_create_2fa_login_challenge("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_factors JSONB;
    v_pref TEXT;
    v_enabled BOOLEAN;
    v_challenge_id UUID;
BEGIN
    SELECT two_factor_enabled, preferred_2fa_method
    INTO v_enabled, v_pref
    FROM public.user_security_settings
    WHERE user_id = p_user_id;

    IF v_enabled IS NOT TRUE THEN
        RETURN jsonb_build_object('requires_2fa', false);
    END IF;

    SELECT COALESCE(jsonb_agg(factor_type), '[]'::jsonb)
    INTO v_factors
    FROM public.user_2fa_factors
    WHERE user_id = p_user_id AND status = 'ACTIVE';

    IF jsonb_array_length(v_factors) = 0 THEN
        RETURN jsonb_build_object('requires_2fa', false);
    END IF;

    INSERT INTO public.two_factor_login_challenges (
        user_id, status, allowed_factors, preferred_factor, expires_at
    ) VALUES (
        p_user_id, 'PENDING', v_factors, v_pref, now() + INTERVAL '10 minutes'
    ) RETURNING id INTO v_challenge_id;

    RETURN jsonb_build_object(
        'requires_2fa', true,
        'login_challenge_id', v_challenge_id,
        'user_id', p_user_id,
        'allowed_factors', v_factors,
        'preferred_factor', v_pref
    );
END;
$$;


ALTER FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") OWNER TO "postgres";

--
