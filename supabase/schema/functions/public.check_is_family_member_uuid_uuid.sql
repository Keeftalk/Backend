-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_is_family_member("uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.family_members
        WHERE (user_id = p_user_id AND member_id = p_member_id)
           OR (user_id = p_member_id AND member_id = p_user_id)
    );
END;
$$;


ALTER FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") OWNER TO "postgres";

--
