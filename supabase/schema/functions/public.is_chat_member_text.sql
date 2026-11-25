-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: is_chat_member("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_chat_member"("target_chat_id" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members
    WHERE chat_id = target_chat_id
    AND user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."is_chat_member"("target_chat_id" "text") OWNER TO "postgres";

--
