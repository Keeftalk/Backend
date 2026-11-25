-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: purge_expired_market_listings(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."purge_expired_market_listings"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    purged_count INT;
BEGIN
    -- Mark active listings older than 30 days as EXPIRED
    UPDATE public.market_listings
    SET status = 'EXPIRED'
    WHERE status = 'ACTIVE' AND expires_at <= NOW();

    -- Delete media for expired listings older than 35 days (grace period)
    DELETE FROM public.market_listing_media
    WHERE listing_id IN (
        SELECT id FROM public.market_listings
        WHERE status = 'EXPIRED' AND expires_at < (NOW() - INTERVAL '5 days')
    );

    GET DIAGNOSTICS purged_count = ROW_COUNT;
    RETURN purged_count;
END;
$$;


ALTER FUNCTION "public"."purge_expired_market_listings"() OWNER TO "postgres";

--
