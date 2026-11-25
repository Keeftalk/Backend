-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: initialize_user_customization(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."initialize_user_customization"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.user_app_customization (
        user_id, 
        onboarding_completed, 
        enabled_modules, 
        bottom_nav_tabs, 
        enabled_fab_actions
    )
    VALUES (
        NEW.id, 
        FALSE, 
        ARRAY['CHATS', 'CALLS', 'SMS', 'AGENDA', 'NOTES', 'EMAIL', 'VAULT', 'BOOKS', 'BROWSER'],
        ARRAY['CHATS', 'SMS', 'VAULT', 'BOOKS'],
        ARRAY['NEW_CHAT', 'NEW_GROUP', 'QR', 'AI', 'DISPLAY', 'MY_BOOKS']
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."initialize_user_customization"() OWNER TO "postgres";

--
