-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_or_create_ai_chat("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    found_chat_id UUID;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();

    -- Check for existing AI chat for this user
    SELECT c.id INTO found_chat_id
    FROM public.chats c
    JOIN public.chat_members cm ON c.id = cm.chat_id
    WHERE c.type = 'AI'
    AND cm.user_id = current_user_id
    LIMIT 1;

    IF found_chat_id IS NOT NULL THEN
        RETURN found_chat_id::text;
    END IF;

    -- Create new chat
    found_chat_id := gen_random_uuid();

    INSERT INTO public.chats (id, name, type, last_message_text)
    VALUES (found_chat_id, 'AI Assistant', 'AI', 'Hello! I am your AI assistant.');

    -- Add user as member
    INSERT INTO public.chat_members (chat_id, user_id)
    VALUES (found_chat_id, current_user_id);

    RETURN found_chat_id::text;
END;
$$;


ALTER FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") OWNER TO "postgres";

--
