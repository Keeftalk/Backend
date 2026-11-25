-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_or_create_official_chat(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_or_create_official_chat"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    official_user_id UUID := 'd9693526-d85e-48e5-ac83-88da31dfcbec'::uuid;
    found_chat_id UUID;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    -- Ensure profile is marked official
    UPDATE public.profiles SET is_official = TRUE WHERE id = official_user_id;

    -- Check for existing Official chat container for this user
    SELECT c.id INTO found_chat_id
    FROM public.chats c
    JOIN public.chat_members cm ON c.id = cm.chat_id
    WHERE c.type = 'OFFICIAL'
    AND cm.user_id = current_user_id
    LIMIT 1;

    IF found_chat_id IS NOT NULL THEN
        RETURN found_chat_id::text;
    END IF;

    -- Create new chat container
    found_chat_id := gen_random_uuid();

    INSERT INTO public.chats (id, name, type, last_message_text, avatar_url)
    VALUES (found_chat_id, 'Keeftalk', 'OFFICIAL', 'Welcome to Keeftalk ?', NULL);

    -- Add user as member
    INSERT INTO public.chat_members (chat_id, user_id)
    VALUES (found_chat_id, current_user_id);

    RETURN found_chat_id::text;
END;
$$;


ALTER FUNCTION "public"."get_or_create_official_chat"() OWNER TO "postgres";

--
