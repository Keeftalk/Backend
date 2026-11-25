-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: recalculate_caller_id_consensus_v3("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_best_first TEXT; v_first_conf REAL; v_best_family TEXT; v_family_conf REAL;
  v_best_business TEXT; v_business_conf REAL; v_is_verified BOOLEAN := FALSE;
  v_v_first TEXT; v_v_family TEXT; v_spam_score REAL := 0.0;
BEGIN
  SELECT caller_id_enabled, split_part(full_name, ' ', 1), substring(full_name from position(' ' in full_name) + 1)
  INTO v_is_verified, v_v_first, v_v_family
  FROM public.profiles
  WHERE phone_hmac = p_phone_hash AND (phone_visibility = 'EVERYONE' OR phone_visibility IS NULL)
  LIMIT 1;

  SELECT candidate_value, COUNT(*)::REAL / 10.0 INTO v_best_first, v_first_conf
  FROM public.caller_contributions WHERE phone_hash = p_phone_hash AND field_type = 'FIRST_NAME'
  GROUP BY candidate_value ORDER BY COUNT(*) DESC LIMIT 1;

  SELECT candidate_value, COUNT(*)::REAL / 10.0 INTO v_best_family, v_family_conf
  FROM public.caller_contributions WHERE phone_hash = p_phone_hash AND field_type = 'FAMILY_NAME'
  GROUP BY candidate_value ORDER BY COUNT(*) DESC LIMIT 1;

  SELECT candidate_value, COUNT(*)::REAL / 5.0 INTO v_best_business, v_business_conf
  FROM public.caller_contributions WHERE phone_hash = p_phone_hash AND field_type = 'BUSINESS'
  GROUP BY candidate_value ORDER BY COUNT(*) DESC LIMIT 1;

  SELECT COALESCE(COUNT(*)::REAL * 0.1, 0.0) INTO v_spam_score
  FROM public.caller_spam_reporters WHERE phone_hash = p_phone_hash;

  INSERT INTO public.caller_identities (
    phone_hash, first_name, family_name, first_name_confidence, family_name_confidence,
    is_verified_profile, verified_first_name, verified_family_name,
    business_name, business_confidence, spam_score, last_updated
  ) VALUES (
    p_phone_hash, v_best_first, v_best_family, COALESCE(v_first_conf, 0.0), COALESCE(v_family_conf, 0.0),
    COALESCE(v_is_verified, FALSE), v_v_first, v_v_family,
    v_best_business, COALESCE(v_business_conf, 0.0), COALESCE(v_spam_score, 0.0), now()
  ) ON CONFLICT (phone_hash) DO UPDATE SET
    first_name = EXCLUDED.first_name, family_name = EXCLUDED.family_name,
    first_name_confidence = EXCLUDED.first_name_confidence,
    family_name_confidence = EXCLUDED.family_name_confidence,
    is_verified_profile = EXCLUDED.is_verified_profile,
    verified_first_name = EXCLUDED.verified_first_name,
    verified_family_name = EXCLUDED.verified_family_name,
    business_name = EXCLUDED.business_name,
    business_confidence = EXCLUDED.business_confidence,
    spam_score = EXCLUDED.spam_score, last_updated = now();

  DELETE FROM public.caller_nicknames WHERE phone_hash = p_phone_hash;
  INSERT INTO public.caller_nicknames (phone_hash, nickname, confidence)
  SELECT phone_hash, candidate_value, COUNT(*)::REAL / 10.0
  FROM public.caller_contributions
  WHERE phone_hash = p_phone_hash AND field_type = 'NICKNAME'
  GROUP BY phone_hash, candidate_value;
END;
$$;


ALTER FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") OWNER TO "postgres";

--
