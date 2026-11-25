-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: is_social_connected("uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Override: Official users are connected to everyone
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id IN (user_id_a, user_id_b) AND is_official = TRUE) THEN
        RETURN TRUE;
    END IF;

    RETURN EXISTS (
        -- Check Contacts
        SELECT 1 FROM public.contacts c
        JOIN public.profiles p ON c.phone = p.phone
        WHERE c.owner_id::uuid = user_id_a AND p.id = user_id_b
        UNION ALL
        -- Check Chat Members
        SELECT 1 FROM public.chat_members cm1
        JOIN public.chat_members cm2 ON cm1.chat_id = cm2.chat_id AND cm1.user_id != cm2.user_id
        JOIN public.chats c ON cm1.chat_id = c.id
        WHERE cm1.user_id::uuid = user_id_a AND cm2.user_id::uuid = user_id_b
        AND c.type = 'ONE_TO_ONE'
    );
END;
$$;


ALTER FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") OWNER TO "postgres";

--
