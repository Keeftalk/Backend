-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_new_message_sync(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_new_message_sync"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.chats
  SET 
    last_message_text = CASE 
      WHEN NEW.type = 'TEXT' THEN NEW.content 
      ELSE '[' || NEW.type || ']' 
    END,
    last_message_time = NEW.created_at,
    last_message_status = NEW.status,
    last_message_sender_id = NEW.sender_id
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_message_sync"() OWNER TO "postgres";

--
