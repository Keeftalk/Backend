-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_file_upload_limits(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_file_upload_limits"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    u_plan public.subscription_plan;
    u_limit BIGINT;
    u_used BIGINT;
    max_file_size BIGINT;
BEGIN
    -- Get plan and current usage from profile SSOT
    SELECT plan_type, storage_limit, storage_used INTO u_plan, u_limit, u_used
    FROM public.profiles WHERE id::text = NEW.owner_id::text;

    -- 1. Check total quota
    IF (u_used + NEW.file_size) > u_limit AND u_plan != 'OFFICIAL' THEN
        RAISE EXCEPTION 'Storage quota exceeded. Please upgrade your Keeftalk plan.';
    END IF;

    -- 2. Check max file size based on plan
    max_file_size := CASE
        WHEN u_plan = 'FREE' THEN 104857600 -- 100MB
        WHEN u_plan IN ('PLUS_MONTHLY', 'PLUS_YEARLY') THEN 1073741824 -- 1GB
        WHEN u_plan = 'OFFICIAL' THEN 107374182400 -- 100GB
        ELSE 5368709120 -- 5GB (Pro/Family)
    END;

    IF NEW.file_size > max_file_size THEN
        RAISE EXCEPTION 'File size exceeds %MB limit for your current plan.', (max_file_size / 1048576);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_file_upload_limits"() OWNER TO "postgres";

--
