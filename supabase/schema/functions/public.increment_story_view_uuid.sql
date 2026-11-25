-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: increment_story_view("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."increment_story_view"("p_story_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.stories SET viewrs = viewrs + 1 WHERE id = p_story_id;
END;
$$;


ALTER FUNCTION "public"."increment_story_view"("p_story_id" "uuid") OWNER TO "postgres";

--
