-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: set_user_plan("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_subscriptions
    SET plan = p_plan
    WHERE user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") OWNER TO "postgres";

--
