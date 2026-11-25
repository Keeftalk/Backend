-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_vault_invite("text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean DEFAULT false) RETURNS TABLE("res_id" "uuid", "res_item_id" "uuid", "res_item_type" "text", "res_wrapped_fek" "jsonb", "res_metadata" "jsonb", "res_token_hash" "text", "res_error_message" "text", "res_is_multi" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_invite RECORD;
    v_view_count INT;
    v_download_count INT;
    v_is_multi BOOLEAN;
BEGIN
    SELECT * INTO v_invite FROM public.vault_share_invites WHERE token_hash = invite_token_hash;

    IF v_invite.id IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, NULL::UUID, NULL::TEXT, NULL::JSONB, NULL::JSONB, NULL::TEXT, 'INVITE_NOT_FOUND'::TEXT, FALSE;
        RETURN;
    END IF;

    IF v_invite.revoked_at IS NOT NULL THEN
        RETURN QUERY SELECT v_invite.id, v_invite.item_id, v_invite.item_type, NULL::JSONB, v_invite.metadata, v_invite.token_hash, 'INVITE_REVOKED'::TEXT, FALSE;
        RETURN;
    END IF;

    IF v_invite.expires_at < now() THEN
        RETURN QUERY SELECT v_invite.id, v_invite.item_id, v_invite.item_type, NULL::JSONB, v_invite.metadata, v_invite.token_hash, 'INVITE_EXPIRED'::TEXT, FALSE;
        RETURN;
    END IF;

    -- Limit check: use_count vs max_uses
    IF v_invite.use_count >= v_invite.max_uses THEN
        RETURN QUERY SELECT v_invite.id, v_invite.item_id, v_invite.item_type, NULL::JSONB, v_invite.metadata, v_invite.token_hash, 'USE_LIMIT_REACHED'::TEXT, FALSE;
        RETURN;
    END IF;

    -- Daily View Limit
    SELECT COUNT(*) INTO v_view_count FROM public.vault_invite_logs
    WHERE invite_id = v_invite.id AND action = 'VIEW' AND created_at > (now() - interval '24 hours');

    IF v_view_count >= v_invite.max_views THEN
        RETURN QUERY SELECT v_invite.id, v_invite.item_id, v_invite.item_type, NULL::JSONB, v_invite.metadata, v_invite.token_hash, 'VIEW_LIMIT_REACHED'::TEXT, FALSE;
        RETURN;
    END IF;

    -- Daily Download/Import Limit
    SELECT COUNT(*) INTO v_download_count FROM public.vault_invite_logs
    WHERE invite_id = v_invite.id AND action IN ('DOWNLOAD', 'IMPORT') AND created_at > (now() - interval '24 hours');

    IF v_download_count >= v_invite.max_downloads THEN
        RETURN QUERY SELECT v_invite.id, v_invite.item_id, v_invite.item_type, NULL::JSONB, v_invite.metadata, v_invite.token_hash, 'DOWNLOAD_LIMIT_REACHED'::TEXT, FALSE;
        RETURN;
    END IF;

    IF log_action THEN
        INSERT INTO public.vault_invite_logs (invite_id, action) VALUES (v_invite.id, 'VIEW');
    END IF;

    SELECT EXISTS (SELECT 1 FROM public.vault_share_invite_items WHERE invite_id = v_invite.id) INTO v_is_multi;

    RETURN QUERY SELECT v_invite.id, v_invite.item_id, v_invite.item_type, v_invite.wrapped_fek, v_invite.metadata, v_invite.token_hash, NULL::TEXT, v_is_multi;
END;
$$;


ALTER FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) OWNER TO "postgres";

--
