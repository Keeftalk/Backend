-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: report_caller_id_spam_v2("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  INSERT INTO public.caller_spam_reporters (user_id, phone_hash)
  VALUES (auth.uid(), p_phone_hash) ON CONFLICT (user_id, phone_hash) DO NOTHING;
  PERFORM public.recalculate_caller_id_consensus_v3(p_phone_hash);
END;
$$;


ALTER FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") OWNER TO "postgres";

--
