-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: internal_random_base32_secret(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."internal_random_base32_secret"("p_length" integer DEFAULT 32) RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    v_result TEXT := '';
    i INT;
    v_rand INT;
BEGIN
    FOR i IN 1..p_length LOOP
        v_rand := floor(random() * 32)::INT + 1;
        v_result := v_result || substr(v_chars, v_rand, 1);
    END LOOP;
    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."internal_random_base32_secret"("p_length" integer) OWNER TO "postgres";

--
