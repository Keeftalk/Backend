-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_extension_rating_stats(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_extension_rating_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.store_extensions
    SET rating_count = (
            SELECT COUNT(*) FROM public.store_ratings WHERE extension_id = COALESCE(NEW.extension_id, OLD.extension_id)
        ),
        rating_avg = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2) FROM public.store_ratings WHERE extension_id = COALESCE(NEW.extension_id, OLD.extension_id)
        ), 0.00),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.extension_id, OLD.extension_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_extension_rating_stats"() OWNER TO "postgres";

--
