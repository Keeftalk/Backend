-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_message_sync_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_message_sync_update"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.chats
    SET 
        last_message_text = NEW.content,
        last_message_time_ms = NEW.timestamp,
        last_message_sender_id = NEW.sender_id,
        last_message_status = NEW.status
    WHERE id = NEW.chat_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_message_sync_update"() OWNER TO "postgres";

--
