-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_user_entitlements("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") RETURNS TABLE("plan" "text", "storage_usage_bytes" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.plan, 
        s.storage_usage_bytes
    FROM public.user_subscriptions s
    WHERE s.user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") OWNER TO "postgres";

--
