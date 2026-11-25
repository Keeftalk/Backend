-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: internal_compute_totp("text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone DEFAULT "now"()) RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE SECURITY DEFINER
    AS $$
DECLARE
    v_key BYTEA;
    v_time_step BIGINT;
    v_msg BYTEA := '\x0000000000000000'::bytea;
    v_hmac BYTEA;
    v_offset INT;
    v_part1 INT;
    v_part2 INT;
    v_part3 INT;
    v_part4 INT;
    v_binary INT;
    v_otp INT;
    i INT;
BEGIN
    v_key := public.internal_base32_decode(p_secret_base32);
    v_time_step := floor(extract(epoch from p_timestamp) / 30)::BIGINT;

    -- Encode BIGINT v_time_step into 8-byte big-endian bytea
    FOR i IN 0..7 LOOP
        v_msg := set_byte(v_msg, 7 - i, ((v_time_step >> (i * 8)) & 255)::INT);
    END LOOP;

    v_hmac := hmac(v_msg, v_key, 'sha1');
    v_offset := (get_byte(v_hmac, length(v_hmac) - 1) & 15);

    v_part1 := (get_byte(v_hmac, v_offset) & 127);
    v_part2 := (get_byte(v_hmac, v_offset + 1) & 255);
    v_part3 := (get_byte(v_hmac, v_offset + 2) & 255);
    v_part4 := (get_byte(v_hmac, v_offset + 3) & 255);

    v_binary := (v_part1 << 24) | (v_part2 << 16) | (v_part3 << 8) | v_part4;
    v_otp := v_binary % 1000000;

    RETURN lpad(v_otp::text, 6, '0');
END;
$$;


ALTER FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) OWNER TO "postgres";

--
