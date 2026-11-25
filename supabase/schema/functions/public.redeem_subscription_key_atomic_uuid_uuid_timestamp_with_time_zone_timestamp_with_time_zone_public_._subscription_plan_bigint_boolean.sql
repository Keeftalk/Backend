-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: redeem_subscription_key_atomic("uuid", "uuid", timestamp with time zone, timestamp with time zone, "public"."subscription_plan", bigint, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- 1. Lock the key for update and check redemption count again
    -- This prevents race conditions
    IF NOT EXISTS (
        SELECT 1 FROM public.subscription_keys
        WHERE id = p_key_id AND redemption_count < max_redemptions
        FOR UPDATE
    ) THEN
        RAISE EXCEPTION 'Key has reached maximum redemptions';
    END IF;

    -- 2. Increment redemption count
    UPDATE public.subscription_keys
    SET redemption_count = redemption_count + 1
    WHERE id = p_key_id;

    -- 3. Record redemption
    INSERT INTO public.subscription_key_redemptions (
        key_id, user_id, redeemed_at, entitlement_start, entitlement_expiration, resulting_plan, resulting_storage
    ) VALUES (
        p_key_id, p_user_id, now(), p_entitlement_start, p_entitlement_expiration, p_plan, p_storage_bytes
    );

    -- 4. Create Entitlement
    INSERT INTO public.user_entitlements (
        user_id, source, plan, storage_bytes, starts_at, expires_at, lifetime, source_key_id, status
    ) VALUES (
        p_user_id, 'redeemed_key', p_plan, p_storage_bytes, p_entitlement_start, p_entitlement_expiration, p_lifetime, p_key_id, 'active'
    );

END;
$$;


ALTER FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) OWNER TO "postgres";

--
