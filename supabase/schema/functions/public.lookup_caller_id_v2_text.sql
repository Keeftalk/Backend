-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: lookup_caller_id_v2("text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) RETURNS TABLE("p_hash" "text", "display_name" "text", "identity_type" "text", "is_verified" boolean, "spam_score" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update Quota
    UPDATE public.caller_id_quotas
    SET daily_lookups = CASE WHEN last_lookup_date < CURRENT_DATE THEN 1 ELSE daily_lookups + 1 END,
        last_lookup_date = CURRENT_DATE
    WHERE user_id = auth.uid();

    RETURN QUERY
    WITH input_hashes AS (
        SELECT UNNEST(phone_hashes) as h
    ),
    verified_identities AS (
        SELECT 
            p.phone_hmac as h,
            p.full_name as name,
            'VERIFIED' as type,
            TRUE as verified
        FROM public.profiles p
        WHERE p.phone_hmac = ANY(phone_hashes)
          AND p.caller_id_enabled = TRUE
          AND (p.phone_visibility = 'EVERYONE' OR p.phone_visibility IS NULL)
    ),
    all_identities AS (
        SELECT 
            id.phone_hash as h,
            id.display_name as name,
            CASE WHEN id.is_verified_profile THEN 'VERIFIED' ELSE 'COMMUNITY' END as type,
            id.is_verified_profile as verified
        FROM public.caller_id_identities id
        WHERE id.phone_hash = ANY(phone_hashes)
    ),
    spam_signals AS (
        SELECT 
            sr.phone_hash as h,
            (COUNT(*)::REAL * 0.1) as score
        FROM public.caller_id_spam_reporters sr
        WHERE sr.phone_hash = ANY(phone_hashes)
        GROUP BY sr.phone_hash
    )
    SELECT
        in_h.h,
        COALESCE(vi.name, ai.name) as display_name,
        COALESCE(vi.type, ai.type, 'UNKNOWN') as identity_type,
        COALESCE(vi.verified, ai.verified, FALSE) as is_verified,
        COALESCE(ss.score, 0.0)::REAL as spam_score
    FROM input_hashes in_h
    LEFT JOIN verified_identities vi ON in_h.h = vi.h
    LEFT JOIN all_identities ai ON in_h.h = ai.h
    LEFT JOIN spam_signals ss ON in_h.h = ss.h;
END;
$$;


ALTER FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) OWNER TO "postgres";

--
