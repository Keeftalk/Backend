-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_my_chats(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_my_chats"() RETURNS TABLE("chat_id" "uuid")
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT chat_id FROM public.chat_members WHERE user_id = auth.uid();
$$;


ALTER FUNCTION "public"."get_my_chats"() OWNER TO "postgres";

--
