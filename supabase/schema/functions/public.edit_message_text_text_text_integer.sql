-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: edit_message("text", "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer DEFAULT 2) RETURNS "void"
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

    -- 1. Authorization: Only sender can edit
    IF v_sender_id != auth.uid()::text THEN
        RAISE EXCEPTION 'Unauthorized: Only the sender can edit this message.';
    END IF;

    -- 2. Time Window: 100 minutes
    IF v_created_at < now() - INTERVAL '100 minutes' THEN
        RAISE EXCEPTION 'Edit window expired (100 minutes).';
    END IF;

    -- 3. Check if already deleted
    IF EXISTS (SELECT 1 FROM public.messages WHERE id::text = p_message_id AND deleted_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Cannot edit a deleted message.';
    END IF;

    -- Update message
    UPDATE public.messages
    SET
        ciphertext = p_ciphertext,
        nonce = p_nonce,
        crypto_version = p_crypto_version,
        edited_at = now(),
        content = '[Edited]' -- Generic placeholder for UI until decrypted
    WHERE id::text = p_message_id;
END;
$$;


ALTER FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) OWNER TO "postgres";

--
