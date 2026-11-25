-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: increment_file_reference("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.files
    SET reference_count = reference_count + 1,
        status = 'ACTIVE',
        deleted_at = NULL
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
    );
END;
$$;


ALTER FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") OWNER TO "postgres";

--
