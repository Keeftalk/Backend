-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contribute_caller_id("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_contribute_enabled BOOLEAN;
BEGIN
    -- Check if calling user has contributions enabled
    SELECT caller_id_contribute INTO v_contribute_enabled
    FROM public.profiles
    WHERE id = auth.uid();

    IF v_contribute_enabled = FALSE THEN
        RETURN;
    END IF;

    -- Upsert contribution
    INSERT INTO public.caller_id_names (phone_identifier, name, contribution_count, confidence_score, last_updated)
    VALUES (p_phone_identifier, p_name, 1, 0.1, now())
    ON CONFLICT (phone_identifier, name) DO UPDATE
    SET contribution_count = caller_id_names.contribution_count + 1,
        confidence_score = LEAST(1.0, caller_id_names.confidence_score + 0.05),
        last_updated = now();
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") OWNER TO "postgres";

--
