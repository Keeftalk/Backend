-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sync_subscription_entitlement("uuid", "public"."subscription_plan", bigint, "text", timestamp with time zone, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
BEGIN
    -- 1. Update or Insert Subscription Record
    INSERT INTO public.subscriptions (user_id, plan, status, purchase_token, order_id, expiry_date, updated_at)
    VALUES (target_user_id, new_plan, new_status, new_purchase_token, new_order_id, new_expiry, now())
    ON CONFLICT (purchase_token) DO UPDATE SET
        status = EXCLUDED.status,
        expiry_date = EXCLUDED.expiry_date,
        updated_at = now();

    -- 2. Update Profile SSOT
    UPDATE public.profiles
    SET plan_type = new_plan,
        storage_limit = new_limit
    WHERE id = target_user_id;

    -- 3. If Family plan, ensure family record exists and link it
    IF new_plan = 'FAMILY_MONTHLY' THEN
        INSERT INTO public.families (owner_id)
        VALUES (target_user_id)
        ON CONFLICT (owner_id) DO NOTHING; -- Assuming owner_id UNIQUE for families if one owner per family

        SELECT id INTO f_id FROM public.families WHERE owner_id = target_user_id;

        -- Auto-add owner to their own family members if not present
        INSERT INTO public.family_members (family_id, user_id)
        VALUES (f_id, target_user_id)
        ON CONFLICT DO NOTHING;

        UPDATE public.profiles SET is_family_owner = TRUE, family_id = f_id WHERE id = target_user_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") OWNER TO "postgres";

--
