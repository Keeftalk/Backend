-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_verify_otp_challenge("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_challenge RECORD;
    v_input_hash TEXT;
    v_dest TEXT;
    v_active_count INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT * INTO v_challenge
    FROM public.two_factor_otp_challenges
    WHERE id = p_challenge_id AND user_id = v_user_id;

    IF v_challenge IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid or expired OTP challenge.');
    END IF;

    IF v_challenge.consumed_at IS NOT NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'This verification code has already been used.');
    END IF;

    IF v_challenge.expires_at < now() THEN
        RETURN jsonb_build_object('success', false, 'message', 'Verification code has expired. Request a new code.');
    END IF;

    IF v_challenge.attempt_count >= v_challenge.max_attempts THEN
        RETURN jsonb_build_object('success', false, 'message', 'Maximum verification attempts exceeded. Request a new code.');
    END IF;

    v_input_hash := encode(digest(trim(p_otp_code), 'sha256'), 'hex');

    IF v_challenge.otp_hash != v_input_hash THEN
        UPDATE public.two_factor_otp_challenges
        SET attempt_count = attempt_count + 1
        WHERE id = p_challenge_id;

        RETURN jsonb_build_object('success', false, 'message', 'Incorrect verification code.');
    END IF;

    -- Mark challenge as consumed
    UPDATE public.two_factor_otp_challenges
    SET consumed_at = now()
    WHERE id = p_challenge_id;

    -- If this was for ENROLLMENT, activate the factor
    IF v_challenge.purpose = 'ENROLLMENT' THEN
        SELECT count(*) INTO v_active_count
        FROM public.user_2fa_factors
        WHERE user_id = v_user_id AND status = 'ACTIVE';

        INSERT INTO public.user_2fa_factors (user_id, factor_type, status, verified_destination, is_preferred, created_at, last_used_at)
        VALUES (v_user_id, v_challenge.factor_type, 'ACTIVE', v_challenge.destination_masked, (v_active_count = 0), now(), now())
        ON CONFLICT (user_id, factor_type) DO UPDATE
        SET status = 'ACTIVE',
            verified_destination = EXCLUDED.verified_destination,
            last_used_at = now();

        UPDATE public.user_security_settings
        SET two_factor_enabled = TRUE,
            preferred_2fa_method = COALESCE(preferred_2fa_method, v_challenge.factor_type),
            updated_at = now()
        WHERE user_id = v_user_id;
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Verification successful.');
END;
$$;


ALTER FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") OWNER TO "postgres";

--
