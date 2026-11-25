-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contribute_caller_id_v3("text", "text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text" DEFAULT NULL::"text", "p_family_name" "text" DEFAULT NULL::"text", "p_nickname" "text" DEFAULT NULL::"text", "p_business_name" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  IF p_first_name IS NOT NULL AND p_first_name != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'FIRST_NAME', p_first_name, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  IF p_family_name IS NOT NULL AND p_family_name != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'FAMILY_NAME', p_family_name, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  IF p_nickname IS NOT NULL AND p_nickname != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'NICKNAME', p_nickname, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  IF p_business_name IS NOT NULL AND p_business_name != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'BUSINESS', p_business_name, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  PERFORM public.recalculate_caller_id_consensus_v3(p_phone_hash);
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") OWNER TO "postgres";

--
