-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sync_time_tracking(bigint, "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog', 'public'
    AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
    END IF;
    IF p_epoch_day IS NULL OR p_feature_key IS NULL OR btrim(p_feature_key) = '' OR p_add_seconds IS NULL OR p_add_seconds <= 0 THEN
        RAISE EXCEPTION 'Invalid time tracking input' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.user_time_tracking (user_id, epoch_day, feature_key, duration_seconds, updated_at)
    VALUES (auth.uid(), p_epoch_day, p_feature_key, p_add_seconds, pg_catalog.now())
    ON CONFLICT (user_id, epoch_day, feature_key)
    DO UPDATE SET
        duration_seconds = public.user_time_tracking.duration_seconds + EXCLUDED.duration_seconds,
        updated_at = pg_catalog.now();
END;
$$;


ALTER FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) OWNER TO "postgres";

--
