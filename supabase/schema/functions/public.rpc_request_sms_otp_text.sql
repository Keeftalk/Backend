-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_request_sms_otp("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text" DEFAULT 'ENROLLMENT'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_phone TEXT;
    v_masked TEXT;
    v_code TEXT;
    v_code_hash TEXT;
    v_challenge_id UUID;
    v_cooldown TIMESTAMPTZ;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT phone INTO v_phone FROM public.profiles WHERE id = v_user_id::text;
    IF v_phone IS NULL OR v_phone = '' THEN
        SELECT phone INTO v_phone FROM auth.users WHERE id = v_user_id;
    END IF;

    IF v_phone IS NULL OR v_phone = '' THEN
        RAISE EXCEPTION 'No phone number registered on profile.';
    END IF;

    -- Mask phone number e.g. +1 *** *** 1234
    IF length(v_phone) > 6 THEN
        v_masked := substr(v_phone, 1, 3) || ' *** *** ' || substr(v_phone, length(v_phone) - 3);
    ELSE
        v_masked := '***' || substr(v_phone, length(v_phone) - 2);
    END IF;

    -- Rate limiting / resend cooldown check
    SELECT resend_cooldown_until INTO v_cooldown
    FROM public.two_factor_otp_challenges
    WHERE user_id = v_user_id AND factor_type = 'sms' AND consumed_at IS NULL
    ORDER BY created_at DESC LIMIT 1;

    IF v_cooldown IS NOT NULL AND v_cooldown > now() THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Please wait before requesting a new SMS code.',
            'cooldown_seconds', ceil(extract(epoch from (v_cooldown - now())))
        );
    END IF;

    v_code := lpad(floor(100000 + random() * 900000)::text, 6, '0');
    v_code_hash := encode(digest(v_code, 'sha256'), 'hex');

    UPDATE public.two_factor_otp_challenges
    SET consumed_at = now()
    WHERE user_id = v_user_id AND factor_type = 'sms' AND consumed_at IS NULL;

    INSERT INTO public.two_factor_otp_challenges (
        user_id, factor_type, purpose, otp_hash, destination_masked, expires_at, resend_cooldown_until
    ) VALUES (
        v_user_id, 'sms', p_purpose, v_code_hash, v_masked, now() + INTERVAL '5 minutes', now() + INTERVAL '60 seconds'
    ) RETURNING id INTO v_challenge_id;

    RETURN jsonb_build_object(
        'success', true,
        'challenge_id', v_challenge_id,
        'masked_destination', v_masked,
        'cooldown_seconds', 60
    );
END;
$$;


ALTER FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") OWNER TO "postgres";

--
