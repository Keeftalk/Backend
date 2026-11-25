-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_vault_share("text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean DEFAULT false) RETURNS TABLE("res_share_id" "uuid", "res_file_id" "uuid", "res_storage_path" "text", "res_wrapped_fek" "jsonb", "res_owner_id" "text", "res_error_message" "text", "res_cooldown_seconds" integer, "res_expires_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_share RECORD;
    v_view_count INT;
    v_last_view TIMESTAMPTZ;
    v_cooldown INT := 0;
BEGIN
    SELECT vs.*, vi.file_id AS actual_file_id,
           f.storage_path, f.owner_id::TEXT AS file_owner
    INTO v_share
    FROM public.vault_shares vs
    JOIN public.vault_items vi ON vs.item_id = vi.id
    JOIN public.files f ON vi.file_id = f.id
    WHERE vs.token = share_token
    LIMIT 1;

    IF v_share.id IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, NULL::UUID, NULL::TEXT, NULL::JSONB,
            NULL::TEXT, 'LINK_NOT_FOUND'::TEXT, 0, NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    IF v_share.is_revoked THEN
        RETURN QUERY SELECT v_share.id, v_share.actual_file_id, NULL::TEXT,
            NULL::JSONB, v_share.file_owner, 'LINK_REVOKED'::TEXT, 0,
            v_share.expires_at;
        RETURN;
    END IF;

    IF v_share.expires_at < now() THEN
        RETURN QUERY SELECT v_share.id, v_share.actual_file_id, NULL::TEXT,
            NULL::JSONB, v_share.file_owner, 'LINK_EXPIRED'::TEXT, 0,
            v_share.expires_at;
        RETURN;
    END IF;

    IF v_share.download_count >= v_share.max_downloads THEN
        RETURN QUERY SELECT v_share.id, v_share.actual_file_id, NULL::TEXT,
            NULL::JSONB, v_share.file_owner, 'DOWNLOAD_LIMIT_REACHED'::TEXT, 0,
            v_share.expires_at;
        RETURN;
    END IF;

    SELECT COUNT(*)::INT, MIN(l.created_at)
    INTO v_view_count, v_last_view
    FROM public.vault_share_logs l
    WHERE l.share_id = v_share.id
      AND l.action = 'VIEW'
      AND l.created_at > now() - interval '24 hours';

    IF v_view_count >= 100 THEN
        v_cooldown := GREATEST(
            0,
            EXTRACT(EPOCH FROM (v_last_view + interval '24 hours' - now()))::INT
        );
        RETURN QUERY SELECT v_share.id, v_share.actual_file_id, NULL::TEXT,
            NULL::JSONB, v_share.file_owner, 'VIEW_LIMIT_REACHED'::TEXT,
            v_cooldown, v_share.expires_at;
        RETURN;
    END IF;

    IF log_action THEN
        INSERT INTO public.vault_share_logs (share_id, action)
        VALUES (v_share.id, 'VIEW');
    END IF;

    RETURN QUERY SELECT v_share.id, v_share.actual_file_id,
        v_share.storage_path, v_share.wrapped_fek, v_share.file_owner,
        NULL::TEXT, 0, v_share.expires_at;
END;
$$;


ALTER FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) OWNER TO "postgres";

--
