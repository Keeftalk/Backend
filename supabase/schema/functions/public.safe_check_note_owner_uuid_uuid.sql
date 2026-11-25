-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: safe_check_note_owner("uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.notes 
    WHERE id = n_id AND owner_id = u_id
  );
$$;


ALTER FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") OWNER TO "postgres";

--
