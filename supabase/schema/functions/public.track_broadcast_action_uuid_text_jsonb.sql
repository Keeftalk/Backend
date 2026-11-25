-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: track_broadcast_action("uuid", "text", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.official_broadcast_actions (broadcast_id, user_id, action_type, metadata)
    VALUES (p_broadcast_id, auth.uid(), p_action_type, p_metadata);
END;
$$;


ALTER FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") OWNER TO "postgres";

--
