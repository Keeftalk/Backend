-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: toggle_pinned_message("uuid", "uuid", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF p_is_pinned THEN
        INSERT INTO public.pinned_messages (chat_id, message_id, pinned_by)
        VALUES (p_chat_id, p_message_id, auth.uid())
        ON CONFLICT (chat_id, message_id) DO NOTHING;
    ELSE
        DELETE FROM public.pinned_messages
        WHERE chat_id::text = p_chat_id::text 
        AND message_id::text = p_message_id::text;
    END IF;
END;
$$;


ALTER FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) OWNER TO "postgres";

--
