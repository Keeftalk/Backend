-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: deduct_prepaid_usage("uuid", numeric, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_balance NUMERIC(18, 6);
    v_pricing_id UUID;
BEGIN
    -- Select current active pricing version
    SELECT id INTO v_pricing_id FROM public.billing_pricing WHERE is_active = TRUE LIMIT 1;

    -- Lock prepaid balance row for atomic update
    SELECT prepaid_balance INTO v_balance
    FROM public.billing_balances
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        -- Auto-initialize balance record if missing
        INSERT INTO public.billing_balances (user_id, prepaid_balance)
        VALUES (p_user_id, 0.000000);
        v_balance := 0.000000;
    END IF;

    IF v_balance < p_amount THEN
        -- Insufficient prepaid balance
        RETURN FALSE;
    END IF;

    -- Deduct balance atomically
    UPDATE public.billing_balances
    SET prepaid_balance = prepaid_balance - p_amount,
        updated_at = now()
    WHERE user_id = p_user_id;

    -- Record immutable financial ledger entry
    INSERT INTO public.billing_ledger (
        user_id,
        transaction_type,
        base_amount,
        maintenance_amount,
        margin_amount,
        total_amount,
        pricing_version_id,
        description,
        idempotency_key
    ) VALUES (
        p_user_id,
        'USAGE_CHARGE',
        p_amount * 0.83, -- Base cost component
        p_amount * 0.12, -- 12% maintenance allocation
        p_amount * 0.05, -- 5% founder margin
        p_amount,
        v_pricing_id,
        p_description,
        p_idempotency_key
    ) ON CONFLICT (idempotency_key) DO NOTHING;

    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") OWNER TO "postgres";

--
