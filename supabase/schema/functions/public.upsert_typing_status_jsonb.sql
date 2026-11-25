-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: upsert_typing_status("jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."upsert_typing_status"("payload" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.typing_status (user_id, partner_id, is_typing, char_count, updated_at)
    VALUES (
        (payload->>'user_id')::uuid,
        (payload->>'partner_id')::uuid,
        (payload->>'is_typing')::boolean,
        (payload->>'char_count')::integer,
        now()
    )
    ON CONFLICT (user_id, partner_id) DO UPDATE SET
        is_typing = EXCLUDED.is_typing,
        char_count = EXCLUDED.char_count,
        updated_at = now();
END;
$$;


ALTER FUNCTION "public"."upsert_typing_status"("payload" "jsonb") OWNER TO "postgres";

--
