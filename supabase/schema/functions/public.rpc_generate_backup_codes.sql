-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: rpc_generate_backup_codes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."rpc_generate_backup_codes"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excluding ambiguous characters O,0,I,1
    v_code TEXT;
    v_hash TEXT;
    v_plain_codes JSONB := '[]'::jsonb;
    i INT;
    j INT;
    v_part1 TEXT;
    v_part2 TEXT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Delete old backup codes for this user
    DELETE FROM public.user_2fa_backup_codes WHERE user_id = v_user_id;

    FOR i IN 1..10 LOOP
        v_part1 := '';
        v_part2 := '';
        FOR j IN 1..4 LOOP
            v_part1 := v_part1 || substr(v_chars, floor(random() * 32)::INT + 1, 1);
            v_part2 := v_part2 || substr(v_chars, floor(random() * 32)::INT + 1, 1);
        END LOOP;
        v_code := v_part1 || '-' || v_part2;
        v_hash := encode(digest(v_code, 'sha256'), 'hex');

        INSERT INTO public.user_2fa_backup_codes (user_id, code_hash, used, created_at)
        VALUES (v_user_id, v_hash, FALSE, now());

        v_plain_codes := v_plain_codes || to_jsonb(v_code);
    END LOOP;

    RETURN jsonb_build_object(
        'success', true,
        'backup_codes', v_plain_codes
    );
END;
$$;


ALTER FUNCTION "public"."rpc_generate_backup_codes"() OWNER TO "postgres";

--
