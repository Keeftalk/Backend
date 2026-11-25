-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: send_nudge("text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
    viewer_name TEXT;
    existing_notif_id UUID;
    total_nudges INT;
BEGIN
    -- 1. Increment global nudge count on profile (if target exists)
    UPDATE public.profiles SET nudges_received = nudges_received + nudge_increment WHERE id = target_id;

    -- 2. Get viewer name with explicit fallback for NULL results
    SELECT COALESCE(full_name, username, 'Someone') INTO viewer_name FROM public.profiles WHERE id = viewer_id;

    -- Crucial: Ensure viewer_name is never null even if SELECT returns no rows
    IF viewer_name IS NULL THEN
        viewer_name := 'Someone';
    END IF;

    -- 3. Check for existing unread nudge from this sender
    SELECT id, nudge_count INTO existing_notif_id, total_nudges
    FROM public.notifications
    WHERE user_id = target_id
    AND source_id = viewer_id::text
    AND is_read = false
    AND type = 'NUDGE'
    LIMIT 1;

    IF existing_notif_id IS NOT NULL THEN
        -- Update existing notification
        UPDATE public.notifications
        SET nudge_count = nudge_count + nudge_increment,
            message = viewer_name || ' nudged you ' || (total_nudges + nudge_increment)::text || ' times.',
            created_at = now()
        WHERE id = existing_notif_id;
    ELSE
        -- Create new notification
        INSERT INTO public.notifications (
            id, user_id, type, priority, title, message, created_at, is_read, source_id, nudge_count
        ) VALUES (
            gen_random_uuid(),
            target_id,
            'NUDGE',
            'HIGH',
            'New Nudge!',
            CASE
                WHEN nudge_increment > 1 THEN viewer_name || ' nudged you ' || nudge_increment::text || ' times.'
                ELSE viewer_name || ' nudged you.'
            END,
            now(),
            false,
            viewer_id::text,
            nudge_increment
        );
    END IF;
END;
$$;


ALTER FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) OWNER TO "postgres";

--
