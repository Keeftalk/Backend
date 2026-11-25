-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_request_email_otp("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text" DEFAULT 'ENROLLMENT'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_email TEXT;
    v_masked TEXT;
    v_code TEXT;
    v_code_hash TEXT;
    v_challenge_id UUID;
    v_cooldown TIMESTAMPTZ;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT email INTO v_email FROM auth.users WHERE id = v_user_id;
    IF v_email IS NULL OR v_email = '' THEN
        RAISE EXCEPTION 'No verified email found for this user account.';
    END IF;

    -- Mask email e.g. m***@example.com
    v_masked := overlay(v_email placing '***' from 2 for position('@' in v_email) - 2);

    -- Rate limiting / resend cooldown check
    SELECT resend_cooldown_until INTO v_cooldown
    FROM public.two_factor_otp_challenges
    WHERE user_id = v_user_id AND factor_type = 'email' AND consumed_at IS NULL
    ORDER BY created_at DESC LIMIT 1;

    IF v_cooldown IS NOT NULL AND v_cooldown > now() THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Please wait before requesting a new code.',
            'cooldown_seconds', ceil(extract(epoch from (v_cooldown - now())))
        );
    END IF;

    -- Generate cryptographically secure 6-digit OTP code
    v_code := lpad(floor(100000 + random() * 900000)::text, 6, '0');
    v_code_hash := encode(digest(v_code, 'sha256'), 'hex');

    -- Invalidate existing unconsumed challenges
    UPDATE public.two_factor_otp_challenges
    SET consumed_at = now()
    WHERE user_id = v_user_id AND factor_type = 'email' AND consumed_at IS NULL;

    INSERT INTO public.two_factor_otp_challenges (
        user_id, factor_type, purpose, otp_hash, destination_masked, expires_at, resend_cooldown_until
    ) VALUES (
        v_user_id, 'email', p_purpose, v_code_hash, v_masked, now() + INTERVAL '10 minutes', now() + INTERVAL '60 seconds'
    ) RETURNING id INTO v_challenge_id;

    RETURN jsonb_build_object(
        'success', true,
        'challenge_id', v_challenge_id,
        'masked_destination', v_masked,
        'cooldown_seconds', 60
    );
END;
$$;


ALTER FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") OWNER TO "postgres";

--
