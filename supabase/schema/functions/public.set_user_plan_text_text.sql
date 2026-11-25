-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: set_user_plan("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := p_user_id::uuid;
    UPDATE public.user_subscriptions
    SET plan = p_plan::public.user_plan,
        storage_limit_gb = CASE WHEN p_plan = 'pro' THEN 100 WHEN p_plan = 'plus' THEN 10 ELSE 1 END,
        updated_at = now()
    WHERE user_id = v_user_id;
END;
$$;


ALTER FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") OWNER TO "postgres";

--
