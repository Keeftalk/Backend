-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: on_message_update_relationship_strength(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."on_message_update_relationship_strength"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    PERFORM public.calculate_relationship_strength(NEW.sender_id::text, cm.user_id::text)
    FROM public.chat_members cm
    JOIN public.chats c ON cm.chat_id = c.id
    WHERE cm.chat_id = NEW.chat_id
    AND cm.user_id::text != NEW.sender_id::text
    AND c.type = 'ONE_TO_ONE';

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_message_update_relationship_strength"() OWNER TO "postgres";

--
