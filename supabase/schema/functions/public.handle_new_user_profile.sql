-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: handle_new_user_profile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_new_user_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (id, email, username, full_name, phone, country, country_code, phone_verified)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NULLIF(NEW.raw_user_meta_data->>'username', ''), 'user_' || substr(NEW.id::text, 1, 8)),
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'phone',
      NEW.raw_user_meta_data->>'country',
      NEW.raw_user_meta_data->>'country_code',
      FALSE
    )
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      username = COALESCE(NULLIF(public.profiles.username, ''), EXCLUDED.username),
      full_name = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
      phone = COALESCE(NULLIF(public.profiles.phone, ''), EXCLUDED.phone),
      country = COALESCE(NULLIF(public.profiles.country, ''), EXCLUDED.country),
      country_code = COALESCE(NULLIF(public.profiles.country_code, ''), EXCLUDED.country_code);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'handle_new_user_profile warning for user %: %', NEW.id, SQLERRM;
  END;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user_profile"() OWNER TO "postgres";

--
