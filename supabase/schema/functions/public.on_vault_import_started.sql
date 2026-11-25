-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: on_vault_import_started(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."on_vault_import_started"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.vault_share_invites
    SET use_count = use_count + 1
    WHERE id = NEW.share_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_vault_import_started"() OWNER TO "postgres";

--
