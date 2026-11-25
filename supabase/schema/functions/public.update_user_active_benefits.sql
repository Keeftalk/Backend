-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_user_active_benefits(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_user_active_benefits"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_user_id UUID;
    best_plan public.subscription_plan;
    total_storage BIGINT;
    base_storage BIGINT := 5368709120; -- 5GB base
BEGIN
    target_user_id := COALESCE(NEW.user_id, OLD.user_id);

    -- 1. Find the "best" active plan
    -- Priority order: OFFICIAL > FAMILY > PRO > PLUS > FREE
    -- We'll use a CASE statement to rank them
    SELECT plan INTO best_plan
    FROM public.user_entitlements
    WHERE user_id = target_user_id
      AND status = 'active'
      AND (expires_at IS NULL OR expires_at > now())
    ORDER BY
        CASE plan
            WHEN 'OFFICIAL' THEN 5
            WHEN 'FAMILY_MONTHLY' THEN 4
            WHEN 'PRO_MONTHLY' THEN 3
            WHEN 'PLUS_YEARLY' THEN 2
            WHEN 'PLUS_MONTHLY' THEN 1
            ELSE 0
        END DESC,
        expires_at DESC NULLS FIRST
    LIMIT 1;

    IF best_plan IS NULL THEN
        best_plan := 'FREE';
    END IF;

    -- 2. Sum up storage (Base + Active Entitlements)
    -- Note: We might want to handle plan-included storage vs extra storage
    -- For simplicity here, we sum storage from all active entitlements that explicitly grant storage
    SELECT COALESCE(SUM(storage_bytes), 0) INTO total_storage
    FROM public.user_entitlements
    WHERE user_id = target_user_id
      AND status = 'active'
      AND (expires_at IS NULL OR expires_at > now());

    -- Update Profile
    UPDATE public.profiles
    SET plan_type = best_plan,
        storage_limit = base_storage + total_storage
    WHERE id = target_user_id;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_user_active_benefits"() OWNER TO "postgres";

--
