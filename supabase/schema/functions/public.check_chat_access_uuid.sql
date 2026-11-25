-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_chat_access("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members 
    WHERE chat_id = chat_uuid AND user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") OWNER TO "postgres";

--
