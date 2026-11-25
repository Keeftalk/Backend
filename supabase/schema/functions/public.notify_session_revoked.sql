-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notify_session_revoked(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."notify_session_revoked"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    PERFORM pg_notify(
        'session_revoked',
        json_build_object(
            'id', OLD.id,
            'user_id', OLD.user_id,
            'device_id', OLD.device_id
        )::text
    );
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."notify_session_revoked"() OWNER TO "postgres";

--
