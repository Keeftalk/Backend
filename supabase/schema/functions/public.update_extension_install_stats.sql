-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_extension_install_stats(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_extension_install_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.store_extensions
    SET install_count = (
            SELECT COUNT(*) FROM public.store_installations WHERE extension_id = NEW.extension_id AND status = 'INSTALLED'
        ),
        updated_at = NOW()
    WHERE id = NEW.extension_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_extension_install_stats"() OWNER TO "postgres";

--
