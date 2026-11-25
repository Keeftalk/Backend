-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_verify_2fa_login_challenge("uuid", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_challenge RECORD;
    v_secret TEXT;
    v_valid BOOLEAN := FALSE;
    v_code_hash TEXT;
    v_backup_rec RECORD;
    v_verification_token TEXT;
BEGIN
    SELECT * INTO v_challenge
    FROM public.two_factor_login_challenges
    WHERE id = p_login_challenge_id;

    IF v_challenge IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid 2FA login challenge.');
    END IF;

    IF v_challenge.status != 'PENDING' THEN
        RETURN jsonb_build_object('success', false, 'message', '2FA login challenge is no longer valid.');
    END IF;

    IF v_challenge.expires_at < now() THEN
        UPDATE public.two_factor_login_challenges SET status = 'EXPIRED' WHERE id = p_login_challenge_id;
        RETURN jsonb_build_object('success', false, 'message', '2FA login challenge has expired.');
    END IF;

    -- Handle Factor Types
    IF p_factor_type = 'totp' THEN
        SELECT totp_secret INTO v_secret
        FROM public.user_2fa_factors
        WHERE user_id = v_challenge.user_id AND factor_type = 'totp' AND status = 'ACTIVE';

        IF v_secret IS NULL THEN
            RETURN jsonb_build_object('success', false, 'message', 'Authenticator app factor is not active.');
        END IF;

        v_valid := public.internal_verify_totp(v_secret, p_code);

    ELSIF p_factor_type IN ('email', 'sms') THEN
        -- Check recent unconsumed OTP challenge
        v_code_hash := encode(digest(trim(p_code), 'sha256'), 'hex');

        SELECT id INTO v_secret
        FROM public.two_factor_otp_challenges
        WHERE user_id = v_challenge.user_id
          AND factor_type = p_factor_type
          AND otp_hash = v_code_hash
          AND consumed_at IS NULL
          AND expires_at > now();

        IF v_secret IS NOT NULL THEN
            v_valid := TRUE;
            UPDATE public.two_factor_otp_challenges SET consumed_at = now() WHERE id = v_secret::UUID;
        END IF;

    ELSIF p_factor_type = 'backup_code' THEN
        v_code_hash := encode(digest(upper(trim(p_code)), 'sha256'), 'hex');

        SELECT * INTO v_backup_rec
        FROM public.user_2fa_backup_codes
        WHERE user_id = v_challenge.user_id AND code_hash = v_code_hash AND used = FALSE;

        IF v_backup_rec IS NOT NULL THEN
            v_valid := TRUE;
            UPDATE public.user_2fa_backup_codes
            SET used = TRUE, used_at = now()
            WHERE id = v_backup_rec.id;
        END IF;
    END IF;

    IF NOT v_valid THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid verification code.');
    END IF;

    -- Issue short-lived verification token to finalize login
    v_verification_token := encode(digest(random()::text || now()::text, 'sha256'), 'hex');

    UPDATE public.two_factor_login_challenges
    SET status = 'VERIFIED',
        verified_at = now(),
        verification_token = v_verification_token
    WHERE id = p_login_challenge_id;

    UPDATE public.user_2fa_factors
    SET last_used_at = now()
    WHERE user_id = v_challenge.user_id AND factor_type = p_factor_type;

    RETURN jsonb_build_object(
        'success', true,
        'verification_token', v_verification_token,
        'user_id', v_challenge.user_id
    );
END;
$$;


ALTER FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") OWNER TO "postgres";

--
