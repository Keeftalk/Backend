-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: complete_user_onboarding("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_app_customization
    SET onboarding_completed = TRUE,
        updated_at = now()
    WHERE user_id = p_user_id;
    
    -- Also ensure an entry exists if for some reason it didn't
    IF NOT FOUND THEN
        INSERT INTO public.user_app_customization (user_id, onboarding_completed)
        VALUES (p_user_id, TRUE)
        ON CONFLICT (user_id) DO UPDATE SET onboarding_completed = TRUE;
    END IF;
END;
$$;


ALTER FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") OWNER TO "postgres";

--
