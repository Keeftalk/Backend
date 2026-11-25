-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: internal_verify_totp("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_now TIMESTAMPTZ := now();
    v_t0 TIMESTAMPTZ := v_now - INTERVAL '30 seconds';
    v_t1 TIMESTAMPTZ := v_now;
    v_t2 TIMESTAMPTZ := v_now + INTERVAL '30 seconds';
BEGIN
    IF p_code IS NULL OR length(trim(p_code)) != 6 THEN
        RETURN FALSE;
    END IF;

    IF public.internal_compute_totp(p_secret_base32, v_t1) = trim(p_code) THEN
        RETURN TRUE;
    END IF;
    IF public.internal_compute_totp(p_secret_base32, v_t0) = trim(p_code) THEN
        RETURN TRUE;
    END IF;
    IF public.internal_compute_totp(p_secret_base32, v_t2) = trim(p_code) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$;


ALTER FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") OWNER TO "postgres";

--
