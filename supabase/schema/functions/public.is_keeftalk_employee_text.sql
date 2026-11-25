-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: is_keeftalk_employee("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_keeftalk_employee"("p_email" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
BEGIN
    RETURN p_email ILIKE '%@keeftalk.com';
END;
$$;


ALTER FUNCTION "public"."is_keeftalk_employee"("p_email" "text") OWNER TO "postgres";

--
