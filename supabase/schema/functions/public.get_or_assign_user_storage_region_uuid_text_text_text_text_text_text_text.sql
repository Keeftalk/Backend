-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_or_assign_user_storage_region("uuid", "text", "text", "text", "text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") RETURNS TABLE("user_id" "uuid", "country_code" character varying, "storage_region" character varying, "private_bucket" "text", "public_bucket" "text", "market_bucket" "text", "detention_bucket" "text", "backups_bucket" "text", "assigned_at" timestamp with time zone, "assignment_version" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Atomically insert assignment if not present
    INSERT INTO public.user_storage_regions (
        user_id,
        country_code,
        storage_region,
        private_bucket,
        public_bucket,
        market_bucket,
        detention_bucket,
        backups_bucket
    ) VALUES (
        p_user_id,
        UPPER(p_country_code),
        UPPER(p_storage_region),
        p_private_bucket,
        p_public_bucket,
        p_market_bucket,
        p_detention_bucket,
        p_backups_bucket
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Return the existing or newly created assignment
    RETURN QUERY
    SELECT
        usr.user_id,
        usr.country_code,
        usr.storage_region,
        usr.private_bucket,
        usr.public_bucket,
        usr.market_bucket,
        usr.detention_bucket,
        usr.backups_bucket,
        usr.assigned_at,
        usr.assignment_version
    FROM public.user_storage_regions usr
    WHERE usr.user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") OWNER TO "postgres";

--
