-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_community_analytics(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_community_analytics"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    total_users BIGINT;
    active_today BIGINT;
    active_this_week BIGINT;
    new_today BIGINT;
    total_messages BIGINT;
    messages_today BIGINT;
    total_storage_bytes BIGINT;
    online_now BIGINT;
    top_countries JSONB;
    daily_growth JSONB;
    message_type_dist JSONB;
    plan_distribution JSONB;
    loyal_paid_users BIGINT;
    paid_over_2_months BIGINT;
    active_trend JSONB;
BEGIN
    -- Check if caller is official
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_official = TRUE) THEN
        RAISE EXCEPTION 'Unauthorized: Team members only.';
    END IF;

    -- Basic Counts
    SELECT count(*) INTO total_users FROM public.profiles;
    SELECT count(*) INTO active_today FROM public.profiles 
    WHERE last_seen > (extract(epoch from (now() - interval '24 hours')) * 1000)::BIGINT;
    SELECT count(*) INTO active_this_week FROM public.profiles 
    WHERE last_seen > (extract(epoch from (now() - interval '7 days')) * 1000)::BIGINT;
    SELECT count(*) INTO new_today FROM public.profiles 
    WHERE join_date > (extract(epoch from date_trunc('day', now())) * 1000)::BIGINT;
    
    -- Engagement
    SELECT count(*) INTO total_messages FROM public.messages;
    SELECT count(*) INTO messages_today FROM public.messages 
    WHERE timestamp > (extract(epoch from date_trunc('day', now())) * 1000)::BIGINT;

    -- Storage
    SELECT COALESCE(sum(file_size), 0) INTO total_storage_bytes FROM public.files;
    
    -- Online now
    SELECT count(*) INTO online_now FROM public.profiles 
    WHERE last_seen > (extract(epoch from (now() - interval '5 minutes')) * 1000)::BIGINT;

    -- Demographics
    SELECT jsonb_agg(country_stats) INTO top_countries FROM (
        SELECT country, count(*) as count
        FROM public.profiles
        WHERE country IS NOT NULL
        GROUP BY country
        ORDER BY count DESC
        LIMIT 5
    ) country_stats;

    -- Daily Growth (last 7 days)
    SELECT jsonb_agg(growth) INTO daily_growth FROM (
        SELECT day, new_users FROM (
            SELECT 
                date_trunc('day', to_timestamp(join_date / 1000))::date as day,
                count(*) as new_users
            FROM public.profiles
            WHERE join_date > (extract(epoch from (now() - interval '7 days')) * 1000)::BIGINT
            GROUP BY 1
            ORDER BY 1 DESC
        ) t
    ) growth;

    -- Message Type Distribution
    SELECT jsonb_agg(t) INTO message_type_dist FROM (
        SELECT type, count(*) as count
        FROM public.messages
        GROUP BY type
        ORDER BY count DESC
    ) t;

    -- Plan Distribution
    SELECT jsonb_agg(p) INTO plan_distribution FROM (
        SELECT plan_type, count(*) as count
        FROM public.profiles
        GROUP BY plan_type
        ORDER BY count DESC
    ) p;

    -- Loyal Paid Users (> 2 months on a non-FREE plan)
    SELECT count(*) INTO loyal_paid_users
    FROM public.profiles
    WHERE plan_type::text != 'FREE' 
    AND join_date < (extract(epoch from (now() - interval '2 months')) * 1000)::BIGINT;

    -- Paid Users Over 2 Months (More specific check)
    SELECT count(*) INTO paid_over_2_months
    FROM public.profiles
    WHERE plan_type::text IN ('PLUS_MONTHLY', 'PLUS_YEARLY', 'PRO_MONTHLY', 'FAMILY_MONTHLY')
    AND join_date < (extract(epoch from (now() - interval '2 months')) * 1000)::BIGINT;

    -- Active User Trend (last 24 hours in 1-hour buckets)
    SELECT jsonb_agg(c) INTO active_trend FROM (
        SELECT 
            count(*) as active_count
        FROM generate_series(now() - interval '23 hours', now(), interval '1 hour') AS bucket
        CROSS JOIN LATERAL (
            SELECT count(*) 
            FROM public.profiles 
            WHERE last_seen > (extract(epoch from bucket) * 1000)::BIGINT
            AND last_seen <= (extract(epoch from (bucket + interval '1 hour')) * 1000)::BIGINT
        ) s
    ) c;

    RETURN jsonb_build_object(
        'total_users', total_users,
        'active_today', active_today,
        'active_this_week', active_this_week,
        'new_today', new_today,
        'total_messages', total_messages,
        'messages_today', messages_today,
        'total_storage_bytes', total_storage_bytes,
        'online_now', online_now,
        'top_countries', COALESCE(top_countries, '[]'::jsonb),
        'daily_growth', COALESCE(daily_growth, '[]'::jsonb),
        'message_type_distribution', COALESCE(message_type_dist, '[]'::jsonb),
        'plan_distribution', COALESCE(plan_distribution, '[]'::jsonb),
        'loyal_paid_users', loyal_paid_users,
        'paid_users_over_2_months', paid_over_2_months,
        'active_user_trend', COALESCE(active_trend, '[]'::jsonb),
        'generated_at', now()
    );
END;
$$;


ALTER FUNCTION "public"."get_community_analytics"() OWNER TO "postgres";

--
