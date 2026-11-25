-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_active_first_contact_policy(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_active_first_contact_policy"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    policy_val JSONB;
BEGIN
    SELECT value INTO policy_val FROM public.app_config WHERE key = 'first_contact_policy';
    RETURN COALESCE(policy_val, '{}'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_active_first_contact_policy"() OWNER TO "postgres";

--
