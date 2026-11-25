-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: lookup_caller_id_v3("text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) RETURNS TABLE("p_hash" "text", "identity_data" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.caller_id_quotas
  SET daily_lookups = CASE WHEN last_lookup_date < CURRENT_DATE THEN 1 ELSE daily_lookups + 1 END,
      last_lookup_date = CURRENT_DATE
  WHERE user_id = auth.uid();

  RETURN QUERY
  WITH input_hashes AS (SELECT UNNEST(phone_hashes) AS h), identities AS (
    SELECT id.phone_hash AS h, jsonb_build_object(
      'firstName', id.first_name, 'familyName', id.family_name,
      'firstNameConfidence', id.first_name_confidence,
      'familyNameConfidence', id.family_name_confidence,
      'verifiedFirstName', id.verified_first_name,
      'verifiedFamilyName', id.verified_family_name,
      'isVerified', id.is_verified_profile, 'businessName', id.business_name,
      'businessConfidence', id.business_confidence, 'spamScore', id.spam_score,
      'nicknames', (SELECT jsonb_agg(jsonb_build_object('nickname', n.nickname, 'confidence', n.confidence))
                    FROM public.caller_nicknames n
                    WHERE n.phone_hash = id.phone_hash AND n.confidence > 0.2)
    ) AS data
    FROM public.caller_identities id WHERE id.phone_hash = ANY(phone_hashes)
  )
  SELECT in_h.h, COALESCE(i.data, '{}'::jsonb)
  FROM input_hashes in_h LEFT JOIN identities i ON in_h.h = i.h;
END;
$$;


ALTER FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) OWNER TO "postgres";

--
