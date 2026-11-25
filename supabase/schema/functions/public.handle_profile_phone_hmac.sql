-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_profile_phone_hmac(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_profile_phone_hmac"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_pepper TEXT;
BEGIN
    SELECT value INTO v_pepper FROM public.caller_id_config WHERE key = 'current_pepper';
    
    IF NEW.phone IS NOT NULL AND NEW.phone != '' THEN
        NEW.phone_hmac := trim(from encode(hmac(NEW.phone::bytea, v_pepper::bytea, 'sha256'), 'base64'));
    ELSE
        NEW.phone_hmac := NULL;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_profile_phone_hmac"() OWNER TO "postgres";

--
