-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_get_2fa_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_get_2fa_status"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_factors JSONB;
    v_has_backup BOOLEAN;
    v_pref TEXT;
    v_enabled BOOLEAN := FALSE;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', id,
            'factor_type', factor_type,
            'status', status,
            'verified_destination', verified_destination,
            'is_preferred', is_preferred,
            'created_at', extract(epoch from created_at)::BIGINT * 1000,
            'last_used_at', CASE WHEN last_used_at IS NOT NULL THEN extract(epoch from last_used_at)::BIGINT * 1000 ELSE NULL END
        )
    ), '[]'::jsonb)
    INTO v_factors
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND status = 'ACTIVE';

    SELECT EXISTS(
        SELECT 1 FROM public.user_2fa_backup_codes
        WHERE user_id = v_user_id AND used = FALSE
    ) INTO v_has_backup;

    SELECT two_factor_enabled, preferred_2fa_method
    INTO v_enabled, v_pref
    FROM public.user_security_settings
    WHERE user_id = v_user_id;

    RETURN jsonb_build_object(
        'two_factor_enabled', COALESCE(v_enabled, FALSE),
        'preferred_method', v_pref,
        'has_backup_codes', v_has_backup,
        'active_factors', v_factors
    );
END;
$$;


ALTER FUNCTION "public"."rpc_get_2fa_status"() OWNER TO "postgres";

--
