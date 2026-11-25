-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_or_create_1to1_chat("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    found_chat_id UUID;
BEGIN
    SELECT cm1.chat_id INTO found_chat_id
    FROM public.chat_members cm1
    JOIN public.chat_members cm2 ON cm1.chat_id = cm2.chat_id
    JOIN public.chats c ON c.id = cm1.chat_id
    WHERE c.type = 'ONE_TO_ONE'
      AND cm1.user_id = auth.uid()
      AND cm2.user_id = other_user_id;

    IF found_chat_id IS NOT NULL THEN
        RETURN found_chat_id;
    END IF;

    INSERT INTO public.chats(type)
    VALUES ('ONE_TO_ONE')
    RETURNING id INTO found_chat_id;

    INSERT INTO public.chat_members(chat_id, user_id)
    VALUES
        (found_chat_id, auth.uid()),
        (found_chat_id, other_user_id);

    RETURN found_chat_id;
END;
$$;


ALTER FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") OWNER TO "postgres";

--
