-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_disable_2fa_method("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_remaining_active INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    DELETE FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND factor_type = p_factor_type;

    SELECT count(*) INTO v_remaining_active
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND status = 'ACTIVE';

    IF v_remaining_active = 0 THEN
        UPDATE public.user_security_settings
        SET two_factor_enabled = FALSE, preferred_2fa_method = NULL
        WHERE user_id = v_user_id;

        DELETE FROM public.user_2fa_backup_codes WHERE user_id = v_user_id;
    END IF;

    RETURN jsonb_build_object('success', true, 'remaining_factors', v_remaining_active);
END;
$$;


ALTER FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") OWNER TO "postgres";

--
