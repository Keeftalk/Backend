-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: internal_base32_decode("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."internal_base32_decode"("p_base32" "text") RETURNS "bytea"
    LANGUAGE "plpgsql" IMMUTABLE SECURITY DEFINER
    AS $$
DECLARE
    v_base32 TEXT := upper(p_base32);
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    v_bits TEXT := '';
    v_char CHAR;
    v_val INT;
    i INT;
    v_byte_count INT;
    v_bytes BYTEA := '\x'::bytea;
    v_byte_val INT;
BEGIN
    FOR i IN 1..length(v_base32) LOOP
        v_char := substr(v_base32, i, 1);
        IF v_char = '=' THEN
            EXIT;
        END IF;
        v_val := position(v_char IN v_chars) - 1;
        IF v_val < 0 THEN
            CONTINUE;
        END IF;
        -- Append 5 bits
        v_bits := v_bits || lpad(to_hex(v_val)::bit(5)::text, 5, '0');
    END LOOP;

    v_byte_count := length(v_bits) / 8;
    FOR i IN 1..v_byte_count LOOP
        v_byte_val := (substr(v_bits, (i - 1) * 8 + 1, 8)::bit(8))::INT;
        v_bytes := v_bytes || set_byte('\x00'::bytea, 0, v_byte_val);
    END LOOP;

    RETURN v_bytes;
END;
$$;


ALTER FUNCTION "public"."internal_base32_decode"("p_base32" "text") OWNER TO "postgres";

--
