-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: increment_import_progress("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."increment_import_progress"("import_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.vault_share_imports
    SET processed_items = processed_items + 1,
        updated_at = now()
    WHERE id = import_id;
END;
$$;


ALTER FUNCTION "public"."increment_import_progress"("import_id" "uuid") OWNER TO "postgres";

--
