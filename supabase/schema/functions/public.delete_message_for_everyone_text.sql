-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: delete_message_for_everyone("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sender_id TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Get message info with explicit type handling
    SELECT sender_id::text, created_at INTO v_sender_id, v_created_at
    FROM public.messages
    WHERE id::text = p_message_id;

    -- 1. Authorization: Only sender can delete for everyone
    IF v_sender_id != auth.uid()::text THEN
        RAISE EXCEPTION 'Unauthorized: Only the sender can delete for everyone.';
    END IF;

    -- 2. Time Window: 10 minutes
    IF v_created_at < now() - INTERVAL '10 minutes' THEN
        RAISE EXCEPTION 'Delete for everyone window expired (10 minutes).';
    END IF;

    -- Update message status
    UPDATE public.messages
    SET
        deleted_at = now(),
        ciphertext = NULL, -- Scrub encrypted content
        nonce = NULL,
        content = '[Deleted]' -- Generic placeholder
    WHERE id::text = p_message_id;

    -- Cleanup attachments associated with this message
    -- Note: reference count cleanup is handled by application logic or triggers if implemented
END;
$$;


ALTER FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") OWNER TO "postgres";

--
