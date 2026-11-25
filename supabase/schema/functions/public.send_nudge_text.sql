-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: send_nudge("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."send_nudge"("target_user_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
    viewer_name TEXT;
BEGIN
    -- Increment nudge count on profile
    UPDATE public.profiles SET nudges_received = nudges_received + 1 WHERE id = target_id;
    
    -- Get viewer name for the notification
    SELECT COALESCE(full_name, username, 'Someone') INTO viewer_name FROM public.profiles WHERE id = viewer_id;
    
    -- Insert into internal notifications table
    INSERT INTO public.notifications (
        id, 
        user_id, 
        type, 
        priority, 
        title, 
        message, 
        created_at, 
        is_read, 
        source_id
    ) VALUES (
        gen_random_uuid(),
        target_id,
        'SYSTEM',
        'HIGH',
        'New Nudge!',
        viewer_name || ' nudged you.',
        now(),
        false,
        viewer_id::text
    );
END;
$$;


ALTER FUNCTION "public"."send_nudge"("target_user_id" "text") OWNER TO "postgres";

--
