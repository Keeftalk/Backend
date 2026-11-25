-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: generate_bulk_redeem_codes(integer, "text", "text", "text", bigint, "text"[], integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text" DEFAULT 'PRO'::"text", "p_plan_type" "text" DEFAULT 'PRO_MONTHLY'::"text", "p_storage_limit" bigint DEFAULT '536870912000'::bigint, "p_feature_keys" "text"[] DEFAULT NULL::"text"[], "p_max_uses" integer DEFAULT 1, "p_expires_in_days" integer DEFAULT NULL::integer) RETURNS TABLE("generated_code" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    i INT;
    v_random_code TEXT;
    v_expiry TIMESTAMPTZ := NULL;
BEGIN
    IF p_expires_in_days IS NOT NULL THEN
        v_expiry := now() + (p_expires_in_days || ' days')::INTERVAL;
    END IF;

    FOR i IN 1..p_count LOOP
        v_random_code := p_prefix || '-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4)) || '-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4));
        
        INSERT INTO public.redeem_codes (
            code, type, plan_type, storage_limit, feature_keys, max_uses, expires_at
        ) VALUES (
            v_random_code, p_type, p_plan_type, p_storage_limit, p_feature_keys, p_max_uses, v_expiry
        ) ON CONFLICT (code) DO NOTHING;

        generated_code := v_random_code;
        RETURN NEXT;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) OWNER TO "postgres";

--
