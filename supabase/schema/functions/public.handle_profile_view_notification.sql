-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_profile_view_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_profile_view_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    viewer_name TEXT;
    owner_enabled BOOLEAN;
    viewer_enabled BOOLEAN;
BEGIN
    SELECT profile_view_history_enabled INTO owner_enabled
    FROM public.user_privacy_settings
    WHERE user_id = NEW.viewed_id;

    SELECT profile_view_history_enabled INTO viewer_enabled
    FROM public.user_privacy_settings
    WHERE user_id = NEW.viewer_id;

    IF COALESCE(owner_enabled, false) AND COALESCE(viewer_enabled, false) THEN
        SELECT full_name INTO viewer_name
        FROM public.profiles
        WHERE id = NEW.viewer_id;

        INSERT INTO public.notifications (user_id, type, title, message, data)
        VALUES (
            NEW.viewed_id,
            'PROFILE_VIEW',
            'Profile View',
            COALESCE(viewer_name, 'Someone') || ' viewed your profile',
            jsonb_build_object('viewer_id', NEW.viewer_id)
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_profile_view_notification"() OWNER TO "postgres";

--
