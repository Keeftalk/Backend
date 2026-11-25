-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_file_access("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        -- 1. User is the physical owner
        SELECT 1 FROM public.files
        WHERE id = target_file_id 
        AND owner_id::text = target_user_id::text
    ) OR EXISTS (
        -- 2. User has a Vault Item for this file
        SELECT 1 FROM public.vault_items
        WHERE file_id = target_file_id 
        AND user_id::text = target_user_id::text
    ) OR EXISTS (
        -- 3. User is a member of a chat where this file is an attachment
        SELECT 1 FROM public.message_attachment ma
        JOIN public.messages m ON ma.message_id = m.id
        JOIN public.chat_members cm ON m.chat_id = cm.chat_id
        WHERE ma.file_id = target_file_id 
        AND cm.user_id::text = target_user_id::text
    );
END;
$$;


ALTER FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") OWNER TO "postgres";

--
