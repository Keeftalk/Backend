-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_heartbeat("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_heartbeat"("uid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.user_presence (user_id, last_seen, is_online)
    VALUES (uid, NOW(), TRUE)
    ON CONFLICT (user_id)
    DO UPDATE SET last_seen = NOW(), is_online = TRUE;
END;
$$;


ALTER FUNCTION "public"."handle_heartbeat"("uid" "uuid") OWNER TO "postgres";

--
