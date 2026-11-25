-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sync_family_member_benefits(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."sync_family_member_benefits"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_owner_id UUID;
    owner_plan public.subscription_plan;
BEGIN
    -- If a new family member is added
    IF TG_OP = 'INSERT' THEN
        SELECT owner_id INTO f_owner_id FROM public.families WHERE id = NEW.family_id;
        SELECT plan_type INTO owner_plan FROM public.profiles WHERE id = f_owner_id;

        IF owner_plan = 'FAMILY_MONTHLY' THEN
            UPDATE public.profiles
            SET plan_type = 'PLUS_MONTHLY', -- Inherit Plus benefits
                storage_limit = 2199023255552, -- 2TB (Shared pool)
                family_id = NEW.family_id
            WHERE id = NEW.user_id;
        END IF;
    END IF;

    -- If a member is removed
    IF TG_OP = 'DELETE' THEN
        UPDATE public.profiles
        SET plan_type = 'FREE',
            storage_limit = 5368709120, -- 5GB
            storage_used = public.calculate_user_storage_usage(OLD.user_id),
            family_id = NULL,
            is_family_owner = FALSE -- Just in case
        WHERE id = OLD.user_id;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."sync_family_member_benefits"() OWNER TO "postgres";

--
