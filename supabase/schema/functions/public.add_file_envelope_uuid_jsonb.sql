-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: add_file_envelope("uuid", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.files
    SET encryption_metadata = jsonb_set(
        COALESCE(encryption_metadata, '{"envelopes": [], "fileIv": ""}'::jsonb),
        '{envelopes}',
        (COALESCE(encryption_metadata->'envelopes', '[]'::jsonb) || new_envelope)
    )
    WHERE id = target_file_id
    AND (
        owner_id::text = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM public.message_attachment ma
            JOIN public.messages m ON ma.message_id = m.id
            JOIN public.chat_members cm ON m.chat_id = cm.chat_id
            WHERE ma.file_id = target_file_id
            AND cm.user_id::text = auth.uid()::text
        )
        OR EXISTS (
            SELECT 1 FROM public.vault_items vi
            WHERE vi.file_id = target_file_id
            AND vi.user_id::text = auth.uid()::text
        )
    )
    AND NOT (COALESCE(encryption_metadata->'envelopes', '[]'::jsonb) @> new_envelope);
END;
$$;


ALTER FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") OWNER TO "postgres";

--
