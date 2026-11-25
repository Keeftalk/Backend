-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contribute_caller_id_batch_v3("jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE v_item JSONB; v_hash TEXT; v_first TEXT; v_family TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_contributions) LOOP
    v_hash := v_item->>'hash'; v_first := v_item->>'first_name'; v_family := v_item->>'family_name';
    IF v_hash IS NOT NULL THEN
      IF v_first IS NOT NULL AND v_first != '' THEN
        INSERT INTO public.caller_contributions VALUES (auth.uid(), v_hash, 'FIRST_NAME', v_first, now(), now())
        ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
      END IF;
      IF v_family IS NOT NULL AND v_family != '' THEN
        INSERT INTO public.caller_contributions VALUES (auth.uid(), v_hash, 'FAMILY_NAME', v_family, now(), now())
        ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
      END IF;
      PERFORM public.recalculate_caller_id_consensus_v3(v_hash);
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") OWNER TO "postgres";

--
