-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sync_chat_status_from_pointers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."sync_chat_status_from_pointers"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- For 1:1 chats, update the last_message_status based on the peer's pointer
    IF EXISTS (SELECT 1 FROM public.chats WHERE id = NEW.chat_id AND type = 'ONE_TO_ONE') THEN
        UPDATE public.chats
        SET last_message_status = CASE 
            WHEN NEW.last_read_message_id IS NOT NULL THEN 'SEEN'
            WHEN NEW.last_delivered_message_id IS NOT NULL THEN 'DELIVERED'
            ELSE last_message_status
        END
        WHERE id = NEW.chat_id 
        AND last_message_id IN (NEW.last_read_message_id, NEW.last_delivered_message_id);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_chat_status_from_pointers"() OWNER TO "postgres";

--
