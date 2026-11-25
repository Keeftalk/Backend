-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_storage_usage("uuid", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_subscriptions
    SET storage_usage_bytes = storage_usage_bytes + p_file_size
    WHERE user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) OWNER TO "postgres";

--
