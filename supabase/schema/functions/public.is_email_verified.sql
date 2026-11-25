-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: is_email_verified(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."is_email_verified"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  confirmed_at TIMESTAMPTZ;
BEGIN
  SELECT email_confirmed_at INTO confirmed_at
  FROM auth.users
  WHERE id = auth.uid();

  RETURN confirmed_at IS NOT NULL;
END;
$$;


ALTER FUNCTION "public"."is_email_verified"() OWNER TO "postgres";

--
