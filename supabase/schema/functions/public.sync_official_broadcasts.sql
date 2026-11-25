-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sync_official_broadcasts(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."sync_official_broadcasts"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID := auth.uid();
    official_chat_id UUID;
    official_user_id UUID := 'd9693526-d85e-48e5-ac83-88da31dfcbec'::uuid;
    user_lang TEXT;
    broadcast_rec RECORD;
BEGIN
    -- 1. Get user preferred language
    SELECT preferred_language INTO user_lang FROM public.profiles WHERE id = current_user_id;
    user_lang := COALESCE(user_lang, 'en');

    -- 2. Ensure official chat container is active
    SELECT get_or_create_official_chat()::UUID INTO official_chat_id;

    -- 3. Sync broadcasts
    FOR broadcast_rec IN
        SELECT * FROM public.broadcasts
        ORDER BY published_at ASC
    LOOP
        INSERT INTO public.messages (
            id, chat_id, sender_id, content, type, timestamp, status, ciphertext, crypto_version
        ) VALUES (
            broadcast_rec.id,
            official_chat_id,
            official_user_id, -- Force official sender
            COALESCE(broadcast_rec.content->>user_lang, broadcast_rec.content->>'en'),
            broadcast_rec.type,
            (extract(epoch from broadcast_rec.published_at) * 1000)::BIGINT,
            'SENT',
            NULL,
            0
        ) ON CONFLICT (id) DO UPDATE SET
            content = EXCLUDED.content,
            sender_id = EXCLUDED.sender_id;
    END LOOP;

    -- 4. Update sync state
    INSERT INTO public.user_broadcast_sync (user_id, last_synced_language, updated_at)
    VALUES (current_user_id, user_lang, now())
    ON CONFLICT (user_id) DO UPDATE SET
        last_synced_language = EXCLUDED.last_synced_language,
        updated_at = now();
END;
$$;


ALTER FUNCTION "public"."sync_official_broadcasts"() OWNER TO "postgres";

--
