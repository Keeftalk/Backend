-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notify_new_message(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."notify_new_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update the last_message info on the chat record automatically
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


ALTER FUNCTION "public"."notify_new_message"() OWNER TO "postgres";

--
