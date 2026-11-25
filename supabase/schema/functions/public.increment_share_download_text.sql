-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: increment_share_download("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."increment_share_download"("share_token" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_id UUID;
BEGIN
    SELECT id INTO v_id
    FROM public.vault_shares
    WHERE token = share_token;

    IF v_id IS NOT NULL THEN
        UPDATE public.vault_shares
        SET download_count = download_count + 1
        WHERE id = v_id;

        INSERT INTO public.vault_share_logs (share_id, action)
        VALUES (v_id, 'DOWNLOAD');
    END IF;
END;
$$;


ALTER FUNCTION "public"."increment_share_download"("share_token" "text") OWNER TO "postgres";

--
