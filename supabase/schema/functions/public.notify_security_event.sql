-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notify_security_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."notify_security_event"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  active_session RECORD;
  anon_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyOTUzNDMsImV4cCI6MjA5Nzg3MTM0M30.vu5Zga2iX37NlDV9v0IgQp_PjDNWJmmqqhrvLJ9Un9E';
BEGIN
  -- Iterate through ALL active sessions for this user
  FOR active_session IN
    SELECT fcm_token FROM public.user_sessions
    WHERE user_id = NEW.user_id AND fcm_token IS NOT NULL
  LOOP
    PERFORM net.http_post(
      url := 'https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || anon_key
      ),
      body := jsonb_build_object(
        'to', active_session.fcm_token,
        'type', 'security_alert',
        'title', 'Security Alert',
        'body', COALESCE(NEW.description, 'A security event occurred on your account.'),
        'ip', NEW.ip_address,
        'city', NEW.city,
        'country', NEW.country
      )
    );
  END LOOP;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_security_event"() OWNER TO "postgres";

--
