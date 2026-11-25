-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: increment_story_like("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."increment_story_like"("p_story_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.stories SET likes_count = likes_count + 1 WHERE id = p_story_id;
END;
$$;


ALTER FUNCTION "public"."increment_story_like"("p_story_id" "uuid") OWNER TO "postgres";

--
