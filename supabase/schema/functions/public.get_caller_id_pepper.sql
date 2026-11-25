-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_caller_id_pepper(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_caller_id_pepper"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
    -- Returns your custom backend salt/pepper string. 
    -- Replace 'Keeftalk_Privacy_Shield_2026' with your production environment variable if needed.
    return 'Keeftalk_Privacy_Shield_2026';
end;
$$;


ALTER FUNCTION "public"."get_caller_id_pepper"() OWNER TO "postgres";

--
