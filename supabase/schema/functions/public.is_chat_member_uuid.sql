-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: is_chat_member("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_chat_member"("c_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.chat_members
        WHERE chat_id = c_id
        AND user_id = auth.uid()
    );
END;
$$;


ALTER FUNCTION "public"."is_chat_member"("c_id" "uuid") OWNER TO "postgres";

--
