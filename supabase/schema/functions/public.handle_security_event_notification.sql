-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_security_event_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_security_event_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.notifications (user_id, type, priority, title, message, data)
    VALUES (
        NEW.user_id,
        'SYSTEM',
        'HIGH',
        'Security Alert',
        NEW.description,
        jsonb_build_object('event_type', NEW.event_type, 'device_id', NEW.device_id)
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_security_event_notification"() OWNER TO "postgres";

--
