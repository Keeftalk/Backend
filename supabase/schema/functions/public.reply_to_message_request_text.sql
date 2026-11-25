-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: reply_to_message_request("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."reply_to_message_request"("p_request_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    req RECORD;
    viewer_id UUID := auth.uid();
BEGIN
    SELECT * INTO req FROM public.message_requests WHERE id::text = p_request_id;
    IF req.id IS NULL THEN
        RAISE EXCEPTION 'Message request not found';
    END IF;

    IF req.recipient_id != viewer_id THEN
        RAISE EXCEPTION 'Only recipient can reply to message request';
    END IF;

    -- Update request status
    UPDATE public.message_requests
    SET recipient_replied = true,
        status = 'converted_to_chat',
        updated_at = now()
    WHERE id = req.id;

    -- Ensure chat is marked or registered as normal chat if needed
    -- (The conversation already exists in chats table)
END;
$$;


ALTER FUNCTION "public"."reply_to_message_request"("p_request_id" "text") OWNER TO "postgres";

--
