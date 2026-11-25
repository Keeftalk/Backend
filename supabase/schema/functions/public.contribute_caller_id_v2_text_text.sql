-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contribute_caller_id_v2("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_new_consensus TEXT;
    v_new_score REAL;
    v_is_owner BOOLEAN := FALSE;
BEGIN
    -- 1. Check if contributor is the owner
    SELECT (phone_hmac = p_phone_hash) INTO v_is_owner
    FROM public.profiles
    WHERE id = v_user_id;

    -- 2. Save unique contribution
    INSERT INTO public.caller_id_contributions (user_id, phone_hash, contributed_name)
    VALUES (v_user_id, p_phone_hash, p_name)
    ON CONFLICT (user_id, phone_hash) DO UPDATE
    SET contributed_name = EXCLUDED.contributed_name;

    -- 3. Calculate Winner
    IF v_is_owner THEN
        v_new_consensus := p_name;
        v_new_score := 1.0;
    ELSE
        -- Priority to owner if they ever contributed
        SELECT c.contributed_name INTO v_new_consensus
        FROM public.caller_id_contributions c
        JOIN public.profiles p ON c.user_id = p.id
        WHERE c.phone_hash = p_phone_hash AND p.phone_hmac = p_phone_hash
        LIMIT 1;

        IF v_new_consensus IS NOT NULL THEN
            v_new_score := 1.0;
            v_is_owner := TRUE;
        ELSE
            -- Majority rule for community
            SELECT name, score INTO v_new_consensus, v_new_score
            FROM (
                SELECT contributed_name as name, LEAST(0.9, COUNT(*)::REAL / 5.0) as score
                FROM public.caller_id_contributions
                WHERE phone_hash = p_phone_hash
                GROUP BY contributed_name
                ORDER BY COUNT(*) DESC
                LIMIT 1
            ) sub;
        END IF;
    END IF;

    -- 4. Sync to master identities
    INSERT INTO public.caller_id_identities (phone_hash, display_name, confidence_score, is_verified_profile, last_updated)
    VALUES (p_phone_hash, v_new_consensus, v_new_score, v_is_owner, now())
    ON CONFLICT (phone_hash) DO UPDATE
    SET display_name = EXCLUDED.display_name,
        confidence_score = EXCLUDED.confidence_score,
        is_verified_profile = EXCLUDED.is_verified_profile,
        last_updated = now();
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") OWNER TO "postgres";

--
