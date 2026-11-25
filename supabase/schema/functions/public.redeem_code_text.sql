-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: redeem_code("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."redeem_code"("p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_code_rec RECORD;
    v_fkey TEXT;
    v_already_redeemed BOOLEAN;
BEGIN
    -- 1. Verify user authentication
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Authentication required. Please log in.');
    END IF;

    -- 2. Lookup code (case-insensitive)
    SELECT * INTO v_code_rec
    FROM public.redeem_codes
    WHERE LOWER(code) = LOWER(TRIM(p_code));

    IF v_code_rec.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid redemption code.');
    END IF;

    IF NOT v_code_rec.is_active THEN
        RETURN jsonb_build_object('success', false, 'error', 'This redemption code has been deactivated.');
    END IF;

    IF v_code_rec.expires_at IS NOT NULL AND v_code_rec.expires_at < now() THEN
        RETURN jsonb_build_object('success', false, 'error', 'This redemption code has expired.');
    END IF;

    IF v_code_rec.max_uses > 0 AND v_code_rec.used_count >= v_code_rec.max_uses THEN
        RETURN jsonb_build_object('success', false, 'error', 'This redemption code has reached its maximum usage limit.');
    END IF;

    -- 3. Check if user already redeemed this code
    SELECT EXISTS (
        SELECT 1 FROM public.redeem_history
        WHERE user_id = v_user_id AND code_id = v_code_rec.id
    ) INTO v_already_redeemed;

    IF v_already_redeemed THEN
        RETURN jsonb_build_object('success', false, 'error', 'You have already redeemed this code.');
    END IF;

    -- 4. Apply Benefits (Subscription / Storage / Entitlements)
    IF v_code_rec.type = 'PRO' OR v_code_rec.type = 'FAMILY' OR v_code_rec.plan_type IS NOT NULL THEN
        UPDATE public.profiles
        SET plan_type = COALESCE(v_code_rec.plan_type, 'PRO_MONTHLY')::public.subscription_plan,
            storage_limit = COALESCE(v_code_rec.storage_limit, 536870912000)
        WHERE id = v_user_id;

        INSERT INTO public.subscriptions (user_id, plan, status, order_id, purchase_token)
        VALUES (
            v_user_id,
            COALESCE(v_code_rec.plan_type, 'PRO_MONTHLY')::public.subscription_plan,
            'active',
            'REDEEM_' || v_code_rec.code,
            'REDEEM_TOKEN_' || v_code_rec.code || '_' || v_user_id
        )
        ON CONFLICT (purchase_token) DO UPDATE SET status = 'active', updated_at = now();
    END IF;

    -- Insert Feature Entitlements
    IF v_code_rec.feature_keys IS NOT NULL AND array_length(v_code_rec.feature_keys, 1) > 0 THEN
        FOREACH v_fkey IN ARRAY v_code_rec.feature_keys LOOP
            INSERT INTO public.user_feature_entitlements (user_id, feature_id, enabled, status)
            VALUES (v_user_id, v_fkey, TRUE, 'ACTIVE')
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;

    -- 5. Record History & Update Usage Count
    INSERT INTO public.redeem_history (user_id, code_id, code)
    VALUES (v_user_id, v_code_rec.id, v_code_rec.code);

    UPDATE public.redeem_codes
    SET used_count = used_count + 1
    WHERE id = v_code_rec.id;

    -- 6. Return Success Response
    RETURN jsonb_build_object(
        'success', true,
        'type', v_code_rec.type,
        'title', 'Redemption Successful!',
        'message', 'Code redeemed successfully. Your account capabilities and feature cloud syncs have been updated.',
        'plan_type', v_code_rec.plan_type
    );
END;
$$;


ALTER FUNCTION "public"."redeem_code"("p_code" "text") OWNER TO "postgres";

--
