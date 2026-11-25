-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: can_request_data_export("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_request_data_export"("p_user_id" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    last_export TIMESTAMPTZ;
BEGIN
    SELECT created_at INTO last_export
    FROM public.data_exports
    WHERE user_id = p_user_id
    ORDER BY created_at DESC
    LIMIT 1;

    IF last_export IS NOT NULL AND last_export > (now() - INTERVAL '90 days') THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."can_request_data_export"("p_user_id" "text") OWNER TO "postgres";

--
