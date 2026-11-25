-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: upsert_user_xp_and_get_rank(bigint, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text" DEFAULT NULL::"text") RETURNS TABLE("global_rank" bigint, "total_readers" bigint, "percentile" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_rank BIGINT;
    v_total BIGINT;
    v_pct INT;
BEGIN
    v_user_id := auth.uid();

    -- Upsert for logged-in user
    IF v_user_id IS NOT NULL THEN
        INSERT INTO public.user_reading_xp (user_id, username, total_xp, updated_at)
        VALUES (v_user_id, COALESCE(p_username, 'Reader'), p_total_xp, NOW())
        ON CONFLICT (user_id) DO UPDATE
        SET total_xp = EXCLUDED.total_xp,
            username = COALESCE(EXCLUDED.username, public.user_reading_xp.username),
            updated_at = NOW();
    END IF;

    -- Calculate rank: count of users with strictly higher total_xp + 1
    SELECT COUNT(*) + 1 INTO v_rank
    FROM public.user_reading_xp
    WHERE total_xp > p_total_xp;

    -- Calculate total registered readers count (at least 1)
    SELECT GREATEST(COUNT(*), 1) INTO v_total
    FROM public.user_reading_xp;

    -- Calculate top percentile (1% to 100%)
    v_pct := GREATEST(1, LEAST(100, ROUND((v_rank::NUMERIC / v_total::NUMERIC) * 100)::INT));

    RETURN QUERY SELECT v_rank, v_total, v_pct;
END;
$$;


ALTER FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") OWNER TO "postgres";

--
