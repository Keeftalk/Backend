-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_begin_totp_enrollment(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_begin_totp_enrollment"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_email TEXT;
    v_secret TEXT;
    v_qr_uri TEXT;
    v_factor_id UUID;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT email INTO v_email FROM auth.users WHERE id = v_user_id;
    IF v_email IS NULL THEN
        v_email := v_user_id::text;
    END IF;

    v_secret := public.internal_random_base32_secret(32);
    v_qr_uri := 'otpauth://totp/Keeftalk:' || v_email || '?secret=' || v_secret || '&issuer=Keeftalk';

    INSERT INTO public.user_2fa_factors (user_id, factor_type, status, totp_secret, created_at)
    VALUES (v_user_id, 'totp', 'PENDING', v_secret, now())
    ON CONFLICT (user_id, factor_type) DO UPDATE
    SET status = 'PENDING', totp_secret = EXCLUDED.totp_secret, created_at = now()
    RETURNING id INTO v_factor_id;

    RETURN jsonb_build_object(
        'factor_id', v_factor_id,
        'secret', v_secret,
        'qr_code_uri', v_qr_uri
    );
END;
$$;


ALTER FUNCTION "public"."rpc_begin_totp_enrollment"() OWNER TO "postgres";

--
