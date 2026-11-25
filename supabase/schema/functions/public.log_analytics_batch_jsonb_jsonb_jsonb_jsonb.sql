-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: log_analytics_batch("jsonb", "jsonb", "jsonb", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb" DEFAULT '[]'::"jsonb", "p_screens" "jsonb" DEFAULT '[]'::"jsonb", "p_chats" "jsonb" DEFAULT '[]'::"jsonb", "p_media" "jsonb" DEFAULT '[]'::"jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    -- Security: Ensure user is authenticated
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Sessions
    IF jsonb_array_length(p_sessions) > 0 THEN
        INSERT INTO public.user_sessions (id, user_id, device_id, session_start, session_end, duration_seconds, platform)
        SELECT
            (val->>'id')::uuid,
            v_user_id, -- Force current authenticated user ID
            val->>'device_id',
            (val->>'session_start')::timestamp with time zone,
            (val->>'session_end')::timestamp with time zone,
            (val->>'duration_seconds')::integer,
            COALESCE(val->>'platform', 'android')
        FROM jsonb_array_elements(p_sessions) AS val
        WHERE (val->>'user_id')::uuid = v_user_id -- Security filter
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Screens
    IF jsonb_array_length(p_screens) > 0 THEN
        INSERT INTO public.screen_events (id, user_id, screen_name, entered_at, exited_at, duration_seconds, chat_id)
        SELECT
            (val->>'id')::uuid,
            v_user_id,
            val->>'screen_name',
            (val->>'entered_at')::timestamp with time zone,
            (val->>'exited_at')::timestamp with time zone,
            (val->>'duration_seconds')::integer,
            val->>'chat_id'
        FROM jsonb_array_elements(p_screens) AS val
        WHERE (val->>'user_id')::uuid = v_user_id
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Chats
    IF jsonb_array_length(p_chats) > 0 THEN
        INSERT INTO public.chat_events (id, user_id, chat_id, event_type, timestamp, metadata)
        SELECT
            (val->>'id')::uuid,
            v_user_id,
            val->>'chat_id',
            val->>'event_type',
            (val->>'timestamp')::timestamp with time zone,
            COALESCE(val->'metadata', '{}'::jsonb)
        FROM jsonb_array_elements(p_chats) AS val
        WHERE (val->>'user_id')::uuid = v_user_id
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Media
    IF jsonb_array_length(p_media) > 0 THEN
        INSERT INTO public.media_events (id, user_id, type, action, size_bytes, timestamp)
        SELECT
            (val->>'id')::uuid,
            v_user_id,
            val->>'type',
            val->>'action',
            (val->>'size_bytes')::bigint,
            (val->>'timestamp')::timestamp with time zone
        FROM jsonb_array_elements(p_media) AS val
        WHERE (val->>'user_id')::uuid = v_user_id
        ON CONFLICT (id) DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") OWNER TO "postgres";

--
