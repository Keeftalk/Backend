-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_verify_totp_enrollment("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_secret TEXT;
    v_valid BOOLEAN;
    v_active_count INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT totp_secret INTO v_secret
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND factor_type = 'totp';

    IF v_secret IS NULL THEN
        RAISE EXCEPTION 'TOTP enrollment has not been initialized.';
    END IF;

    v_valid := public.internal_verify_totp(v_secret, p_totp_code);
    IF NOT v_valid THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid 6-digit TOTP code. Check your authenticator app time sync.');
    END IF;

    -- Check if other active factors exist
    SELECT count(*) INTO v_active_count
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND status = 'ACTIVE';

    UPDATE public.user_2fa_factors
    SET status = 'ACTIVE', last_used_at = now(), is_preferred = (v_active_count = 0)
    WHERE user_id = v_user_id AND factor_type = 'totp';

    -- Update overall security settings
    INSERT INTO public.user_security_settings (user_id, two_factor_enabled, preferred_2fa_method, updated_at)
    VALUES (v_user_id, TRUE, 'totp', now())
    ON CONFLICT (user_id) DO UPDATE
    SET two_factor_enabled = TRUE,
        preferred_2fa_method = COALESCE(user_security_settings.preferred_2fa_method, 'totp'),
        updated_at = now();

    RETURN jsonb_build_object('success', true, 'message', 'Authenticator app enabled successfully.');
END;
$$;


ALTER FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") OWNER TO "postgres";

--
