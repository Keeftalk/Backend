-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sync_chat_last_message(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."sync_chat_last_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    UPDATE public.chats
    SET last_message_id = NEW.id,
        last_message_text = NEW.content,
        last_message_time = NEW.created_at,
        last_message_status = NEW.status,
        last_message_sender_id = NEW.sender_id,
        updated_at = now()
    WHERE id = NEW.chat_id;

  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE public.chats
    SET last_message_status = NEW.status,
        updated_at = now()
    WHERE id = NEW.chat_id
      AND last_message_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_chat_last_message"() OWNER TO "postgres";

--
