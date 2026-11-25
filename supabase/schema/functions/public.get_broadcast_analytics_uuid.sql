-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_broadcast_analytics("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    view_count BIGINT;
    click_count BIGINT;
    link_open_count BIGINT;
BEGIN
    -- Check if caller is official
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_official = TRUE) THEN
        RAISE EXCEPTION 'Unauthorized.';
    END IF;

    SELECT count(*) INTO view_count FROM public.official_broadcast_actions WHERE broadcast_id = p_broadcast_id AND action_type = 'VIEW';
    SELECT count(*) INTO click_count FROM public.official_broadcast_actions WHERE broadcast_id = p_broadcast_id AND action_type = 'CLICK';
    SELECT count(*) INTO link_open_count FROM public.official_broadcast_actions WHERE broadcast_id = p_broadcast_id AND action_type = 'LINK_OPEN';

    RETURN jsonb_build_object(
        'views', view_count,
        'clicks', click_count,
        'link_opens', link_open_count
    );
END;
$$;


ALTER FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") OWNER TO "postgres";

--
