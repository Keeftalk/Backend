-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: delete_expired_messages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."delete_expired_messages"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  DELETE FROM public.messages
  WHERE id IN (
    SELECT m.id 
    FROM public.messages m
    JOIN public.chats c ON m.chat_id = c.id
    WHERE c.auto_delete_timer IS NOT NULL
    AND (EXTRACT(EPOCH FROM NOW()) * 1000) > (m.timestamp + c.auto_delete_timer)
  );
END;
$$;


ALTER FUNCTION "public"."delete_expired_messages"() OWNER TO "postgres";

--
