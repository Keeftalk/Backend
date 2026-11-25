-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: report_caller_id_spam("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.caller_id_spam_reports (phone_identifier, report_count, spam_score, last_updated)
    VALUES (p_phone_identifier, 1, 0.1, now())
    ON CONFLICT (phone_identifier) DO UPDATE
    SET report_count = caller_id_spam_reports.report_count + 1,
        spam_score = LEAST(1.0, caller_id_spam_reports.spam_score + 0.1),
        last_updated = now();
END;
$$;


ALTER FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") OWNER TO "postgres";

--
