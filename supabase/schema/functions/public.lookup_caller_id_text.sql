-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: lookup_caller_id("text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) RETURNS TABLE("number" "text", "display_name" "text", "identity_type" "text", "is_verified" boolean, "spam_score" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    WITH input_numbers AS (
        SELECT UNNEST(phone_numbers) as num
    ),
    verified_identities AS (
        -- Priority 1: Verified Keeftalk Accounts
        -- Only if user has caller_id_enabled = TRUE
        SELECT
            p.phone as num,
            p.full_name as name,
            'VERIFIED' as type,
            TRUE as verified
        FROM public.profiles p
        WHERE p.phone = ANY(phone_numbers)
          AND p.caller_id_enabled = TRUE
          AND (p.phone_visibility = 'EVERYONE' OR p.phone_visibility IS NULL)
    ),
    community_identities AS (
        -- Priority 2: Community data
        -- Select name with highest contribution count, requiring at least 1 contribution
        SELECT DISTINCT ON (phone_identifier)
            phone_identifier as num,
            cn.name,
            'COMMUNITY' as type,
            FALSE as verified
        FROM public.caller_id_names cn
        WHERE cn.phone_identifier = ANY(phone_numbers)
          AND cn.contribution_count >= 1
        ORDER BY phone_identifier, contribution_count DESC
    )
    SELECT
        in_n.num,
        COALESCE(vi.name, ci.name) as display_name,
        COALESCE(vi.type, ci.type, 'UNKNOWN') as identity_type,
        COALESCE(vi.verified, FALSE) as is_verified,
        COALESCE(sr.spam_score, 0.0) as spam_score
    FROM input_numbers in_n
    LEFT JOIN verified_identities vi ON in_n.num = vi.num
    LEFT JOIN community_identities ci ON in_n.num = ci.num
    LEFT JOIN public.caller_id_spam_reports sr ON in_n.num = sr.phone_identifier;
END;
$$;


ALTER FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) OWNER TO "postgres";

--
