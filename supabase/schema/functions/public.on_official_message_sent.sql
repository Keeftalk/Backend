-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: on_official_message_sent(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."on_official_message_sent"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    is_official_sender BOOLEAN;
    chat_type TEXT;
BEGIN
    -- Only promote if sender has is_official flag
    SELECT is_official INTO is_official_sender FROM public.profiles WHERE id = NEW.sender_id::uuid;
    -- chat_id might be stored as TEXT in messages but is UUID in chats
    SELECT type INTO chat_type FROM public.chats WHERE id = NEW.chat_id::uuid;

    IF is_official_sender AND chat_type = 'OFFICIAL' THEN
        INSERT INTO public.broadcasts (id, sender_id, content, type, published_at)
        VALUES (
            NEW.id::uuid,
            NEW.sender_id::uuid,
            jsonb_build_object('en', NEW.content),
            NEW.type,
            now()
        ) ON CONFLICT (id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_official_message_sent"() OWNER TO "postgres";

--
