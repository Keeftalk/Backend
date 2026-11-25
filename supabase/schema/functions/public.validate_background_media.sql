-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: validate_background_media(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."validate_background_media"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    total_count INTEGER;
    image_count INTEGER;
    video_count INTEGER;
BEGIN
    -- Check orientation and resolution: landscape only, min FHD (width >= height AND width >= 1080)
    IF NEW.width < NEW.height OR NEW.width < 1080 THEN
        RAISE EXCEPTION 'Background media must be landscape and at least FHD resolution (1080p).';
    END IF;

    -- Check video duration
    IF NEW.media_type = 'VIDEO' AND (NEW.duration_seconds IS NULL OR NEW.duration_seconds > 60 OR NEW.duration_seconds <= 0) THEN
        RAISE EXCEPTION 'Background video duration must be 60 seconds or less.';
    END IF;

    -- Check counts
    SELECT COUNT(*) INTO total_count FROM public.profile_background_media WHERE user_id = NEW.user_id AND id != NEW.id;
    IF total_count >= 5 THEN
        RAISE EXCEPTION 'Maximum 5 background media items allowed per profile.';
    END IF;

    IF NEW.media_type = 'IMAGE' THEN
        SELECT COUNT(*) INTO image_count FROM public.profile_background_media WHERE user_id = NEW.user_id AND media_type = 'IMAGE' AND id != NEW.id;
        IF image_count >= 4 THEN
            RAISE EXCEPTION 'Maximum 4 background images allowed per profile.';
        END IF;
    ELSIF NEW.media_type = 'VIDEO' THEN
        SELECT COUNT(*) INTO video_count FROM public.profile_background_media WHERE user_id = NEW.user_id AND media_type = 'VIDEO' AND id != NEW.id;
        IF video_count >= 1 THEN
            RAISE EXCEPTION 'Maximum 1 background video allowed per profile.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_background_media"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
