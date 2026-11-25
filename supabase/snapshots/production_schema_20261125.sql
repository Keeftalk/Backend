


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE SCHEMA IF NOT EXISTS "security_private";


ALTER SCHEMA "security_private" OWNER TO "postgres";


CREATE TYPE "public"."group_role" AS ENUM (
    'owner',
    'admin',
    'member'
);


ALTER TYPE "public"."group_role" OWNER TO "postgres";


CREATE TYPE "public"."notification_type" AS ENUM (
    'story_like',
    'multi_device',
    'login_attempt',
    'security_alert',
    'app_broadcast',
    'system'
);


ALTER TYPE "public"."notification_type" OWNER TO "postgres";


CREATE TYPE "public"."subscription_plan" AS ENUM (
    'FREE',
    'PLUS_MONTHLY',
    'PLUS_YEARLY',
    'PRO_MONTHLY',
    'FAMILY_MONTHLY',
    'OFFICIAL'
);


ALTER TYPE "public"."subscription_plan" OWNER TO "postgres";


CREATE TYPE "public"."user_plan" AS ENUM (
    'free',
    'plus',
    'pro'
);


ALTER TYPE "public"."user_plan" OWNER TO "postgres";


CREATE TYPE "public"."verification_status" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE "public"."verification_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.files
    SET encryption_metadata = jsonb_set(
        COALESCE(encryption_metadata, '{"envelopes": [], "fileIv": ""}'::jsonb),
        '{envelopes}',
        (COALESCE(encryption_metadata->'envelopes', '[]'::jsonb) || new_envelope)
    )
    WHERE id = target_file_id
    AND (
        owner_id::text = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM public.message_attachment ma
            JOIN public.messages m ON ma.message_id = m.id
            JOIN public.chat_members cm ON m.chat_id = cm.chat_id
            WHERE ma.file_id = target_file_id
            AND cm.user_id::text = auth.uid()::text
        )
        OR EXISTS (
            SELECT 1 FROM public.vault_items vi
            WHERE vi.file_id = target_file_id
            AND vi.user_id::text = auth.uid()::text
        )
    )
    AND NOT (COALESCE(encryption_metadata->'envelopes', '[]'::jsonb) @> new_envelope);
END;
$$;


ALTER FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    u_a UUID := user_id_a::uuid;
    u_b UUID := user_id_b::uuid;
    msg_count INT;
    last_interaction TIMESTAMPTZ;
    new_score FLOAT;
BEGIN
    SELECT
        COUNT(*),
        MAX(created_at)
    INTO msg_count, last_interaction
    FROM public.messages m
    JOIN public.chat_members cm1 ON m.chat_id = cm1.chat_id AND cm1.user_id::text = user_id_a
    JOIN public.chat_members cm2 ON m.chat_id = cm2.chat_id AND cm2.user_id::text = user_id_b
    WHERE m.created_at > now() - interval '30 days';

    new_score := LEAST(1.0, (LOG(GREATEST(1, msg_count)) / 2.0));

    IF last_interaction < now() - interval '7 days' THEN
        new_score := new_score * 0.7;
    END IF;

    INSERT INTO public.relationship_intelligence (user_a, user_b, strength_score, last_interaction_at, interaction_count_30d, updated_at)
    VALUES (u_a, u_b, new_score, last_interaction, msg_count, now())
    ON CONFLICT (user_a, user_b) DO UPDATE SET
        strength_score = EXCLUDED.strength_score,
        last_interaction_at = EXCLUDED.last_interaction_at,
        interaction_count_30d = EXCLUDED.interaction_count_30d,
        updated_at = now();
END;
$$;


ALTER FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
    total_usage BIGINT;
BEGIN
    -- Check if user is in a family (Directly from profile)
    SELECT family_id INTO f_id FROM public.profiles WHERE id = target_user_id::uuid;

    IF f_id IS NOT NULL THEN
        -- Shared family usage: sum of all files owned by all family members
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::text IN (SELECT id::text FROM public.profiles WHERE family_id = f_id)
        AND (status = 'ACTIVE' OR status IS NULL);
    ELSE
        -- Personal usage
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::text = target_user_id::text
        AND (status = 'ACTIVE' OR status IS NULL);
    END IF;

    RETURN COALESCE(total_usage, 0);
END;
$$;


ALTER FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
    total_usage BIGINT;
BEGIN
    SELECT family_id INTO f_id FROM public.profiles WHERE id = target_user_id;

    IF f_id IS NOT NULL THEN
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::uuid IN (SELECT id FROM public.profiles WHERE family_id = f_id)
        AND (status != 'DELETED' OR status IS NULL);
    ELSE
        SELECT SUM(COALESCE(file_size, 0) + COALESCE(thumbnail_size, 0))
        INTO total_usage
        FROM public.files
        WHERE owner_id::uuid = target_user_id
        AND (status != 'DELETED' OR status IS NULL);
    END IF;

    RETURN COALESCE(total_usage, 0);
END;
$$;


ALTER FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_request_data_export"("p_user_id" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    last_export TIMESTAMPTZ;
BEGIN
    SELECT created_at INTO last_export
    FROM public.data_exports
    WHERE user_id = p_user_id
    ORDER BY created_at DESC
    LIMIT 1;

    IF last_export IS NOT NULL AND last_export > (now() - INTERVAL '90 days') THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."can_request_data_export"("p_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
DECLARE
    v_user_id uuid;
    v_limit_gb numeric;
    v_current_bytes bigint;
    v_limit_bytes bigint;
BEGIN
    v_user_id := p_user_id::uuid;
    SELECT storage_limit_gb INTO v_limit_gb FROM public.user_subscriptions WHERE user_id = v_user_id;
    IF v_limit_gb IS NULL THEN v_limit_gb := 1; END IF;
    SELECT total_size_bytes INTO v_current_bytes FROM public.user_storage WHERE user_id = v_user_id;
    IF v_current_bytes IS NULL THEN v_current_bytes := 0; END IF;
    v_limit_bytes := v_limit_gb * 1024 * 1024 * 1024;
    IF (v_current_bytes + p_file_size > v_limit_bytes) THEN
        RETURN json_build_object('allowed', false, 'reason', 'storage_limit_exceeded');
    ELSE
        RETURN json_build_object('allowed', true);
    END IF;
END;
$$;


ALTER FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_plan TEXT;
    v_usage BIGINT;
    v_limit BIGINT;
BEGIN
    SELECT plan, storage_usage_bytes INTO v_plan, v_usage 
    FROM public.user_subscriptions WHERE user_id = p_user_id;

    -- Define limits in bytes
    v_limit := CASE 
        WHEN v_plan = 'free'     THEN 1024 * 1024 * 1024          -- 1GB
        WHEN v_plan = 'plus'     THEN 10 * 1024 * 1024 * 1024     -- 10GB
        WHEN v_plan = 'pro'      THEN 50 * 1024 * 1024 * 1024     -- 50GB
        WHEN v_plan = 'creator'  THEN 200 * 1024 * 1024 * 1024    -- 200GB
        WHEN v_plan = 'business' THEN 1024 * 1024 * 1024 * 1024   -- 1TB
        ELSE 1024 * 1024 * 1024
    END;

    -- Special Rule: Free users can keep sending media after 1GB, but MUST compress it
    IF v_plan = 'free' AND v_usage >= v_limit THEN
        RETURN jsonb_build_object('allowed', true, 'require_compression', true);
    -- Paid users block when absolutely full
    ELSIF v_usage + p_file_size > v_limit THEN
        RETURN jsonb_build_object('allowed', false, 'reason', 'storage_full');
    -- Normal operation
    ELSE
        RETURN jsonb_build_object('allowed', true, 'require_compression', false);
    END IF;
END;
$$;


ALTER FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_can_message"("target_user_id" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
    policy JSONB;
    model TEXT;
    is_connected BOOLEAN;
    is_blocked BOOLEAN;
    existing_req RECORD;
    active_chat_id TEXT;
BEGIN
    -- Self check
    IF viewer_id = target_id THEN
        RETURN jsonb_build_object('allowed', false, 'reason', 'Cannot message yourself');
    END IF;

    -- Check if blocked
    SELECT EXISTS (
        SELECT 1 FROM public.blocked_users
        WHERE (blocker_id::uuid = viewer_id AND blocked_id = target_id)
           OR (blocker_id::uuid = target_id AND blocked_id = viewer_id)
    ) INTO is_blocked;

    IF is_blocked THEN
        RETURN jsonb_build_object('allowed', false, 'reason', 'User is blocked');
    END IF;

    -- Check if socially connected (contacts or existing ONE_TO_ONE chat)
    SELECT public.is_social_connected(viewer_id, target_id) INTO is_connected;

    IF is_connected THEN
        RETURN jsonb_build_object('allowed', true, 'isNormalChat', true);
    END IF;

    -- Fetch policy
    SELECT public.get_active_first_contact_policy() INTO policy;
    model := COALESCE(policy->>'model', 'ONE_MESSAGE');

    IF model = 'DISABLED' THEN
        RETURN jsonb_build_object('allowed', false, 'reason', 'First-contact messaging is disabled by policy');
    END IF;

    -- Check existing message request
    SELECT * INTO existing_req
    FROM public.message_requests
    WHERE ((sender_id = viewer_id AND recipient_id = target_id) OR (sender_id = target_id AND recipient_id = viewer_id))
    AND status NOT IN ('declined', 'blocked', 'expired', 'cancelled');

    IF existing_req.id IS NOT NULL THEN
        IF existing_req.status = 'converted_to_chat' OR existing_req.recipient_replied THEN
            RETURN jsonb_build_object('allowed', true, 'isNormalChat', true, 'requestId', existing_req.id);
        ELSIF existing_req.sender_id = viewer_id THEN
            -- Check message limit before reply
            DECLARE
                max_msgs INT := COALESCE((policy->>'max_messages_before_reply')::int, 1);
            BEGIN
                IF existing_req.messages_sent >= max_msgs THEN
                    RETURN jsonb_build_object('allowed', false, 'reason', 'Waiting for recipient reply before sending more messages', 'requestId', existing_req.id);
                ELSE
                    RETURN jsonb_build_object('allowed', true, 'isNormalChat', false, 'requestId', existing_req.id, 'remainingMessages', max_msgs - existing_req.messages_sent);
                END IF;
            END;
        ELSE
            -- Recipient viewing sender request
            RETURN jsonb_build_object('allowed', true, 'isNormalChat', false, 'requestId', existing_req.id, 'incomingRequest', true);
        END IF;
    END IF;

    -- No existing request, allowed to initiate first contact
    RETURN jsonb_build_object('allowed', true, 'isNormalChat', false, 'canInitiateFirstContact', true, 'policy', policy);
END;
$$;


ALTER FUNCTION "public"."check_can_message"("target_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members 
    WHERE chat_id = chat_uuid AND user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_family_member_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_count INT;
    max_allowed INT;
BEGIN
    SELECT COUNT(*) INTO current_count FROM public.family_members WHERE family_id = NEW.family_id AND status = 'ACTIVE';
    SELECT max_total_users INTO max_allowed FROM public.family_groups WHERE id = NEW.family_id;

    IF current_count >= COALESCE(max_allowed, 6) THEN
        RAISE EXCEPTION 'Family member limit reached (Maximum % total members allowed).', COALESCE(max_allowed, 6);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_family_member_limit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_family_member_removal"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF OLD.role = 'member' AND CURRENT_TIMESTAMP < OLD.eligible_for_removal_at THEN
        RAISE EXCEPTION 'Family members cannot be removed until 1 year has passed since being added (Eligible for removal after %).', OLD.eligible_for_removal_at;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."check_family_member_removal"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        -- 1. User is the physical owner
        SELECT 1 FROM public.files
        WHERE id = target_file_id 
        AND owner_id::text = target_user_id::text
    ) OR EXISTS (
        -- 2. User has a Vault Item for this file
        SELECT 1 FROM public.vault_items
        WHERE file_id = target_file_id 
        AND user_id::text = target_user_id::text
    ) OR EXISTS (
        -- 3. User is a member of a chat where this file is an attachment
        SELECT 1 FROM public.message_attachment ma
        JOIN public.messages m ON ma.message_id = m.id
        JOIN public.chat_members cm ON m.chat_id = cm.chat_id
        WHERE ma.file_id = target_file_id 
        AND cm.user_id::text = target_user_id::text
    );
END;
$$;


ALTER FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.family_members
        WHERE (user_id = p_user_id AND member_id = p_member_id)
           OR (user_id = p_member_id AND member_id = p_user_id)
    );
END;
$$;


ALTER FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_membership"("p_chat_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members
    WHERE chat_id = p_chat_id
    AND user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."check_membership"("p_chat_id" "uuid") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."cleanup_expired_entitlements"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_entitlements
    SET status = 'expired'
    WHERE status = 'active'
      AND expires_at IS NOT NULL
      AND expires_at < now();
END;
$$;


ALTER FUNCTION "public"."cleanup_expired_entitlements"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_app_customization
    SET onboarding_completed = TRUE,
        updated_at = now()
    WHERE user_id = p_user_id;
    
    -- Also ensure an entry exists if for some reason it didn't
    IF NOT FOUND THEN
        INSERT INTO public.user_app_customization (user_id, onboarding_completed)
        VALUES (p_user_id, TRUE)
        ON CONFLICT (user_id) DO UPDATE SET onboarding_completed = TRUE;
    END IF;
END;
$$;


ALTER FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_contribute_enabled BOOLEAN;
BEGIN
    -- Check if calling user has contributions enabled
    SELECT caller_id_contribute INTO v_contribute_enabled
    FROM public.profiles
    WHERE id = auth.uid();

    IF v_contribute_enabled = FALSE THEN
        RETURN;
    END IF;

    -- Upsert contribution
    INSERT INTO public.caller_id_names (phone_identifier, name, contribution_count, confidence_score, last_updated)
    VALUES (p_phone_identifier, p_name, 1, 0.1, now())
    ON CONFLICT (phone_identifier, name) DO UPDATE
    SET contribution_count = caller_id_names.contribution_count + 1,
        confidence_score = LEAST(1.0, caller_id_names.confidence_score + 0.05),
        last_updated = now();
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE v_item JSONB; v_hash TEXT; v_first TEXT; v_family TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_contributions) LOOP
    v_hash := v_item->>'hash'; v_first := v_item->>'first_name'; v_family := v_item->>'family_name';
    IF v_hash IS NOT NULL THEN
      IF v_first IS NOT NULL AND v_first != '' THEN
        INSERT INTO public.caller_contributions VALUES (auth.uid(), v_hash, 'FIRST_NAME', v_first, now(), now())
        ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
      END IF;
      IF v_family IS NOT NULL AND v_family != '' THEN
        INSERT INTO public.caller_contributions VALUES (auth.uid(), v_hash, 'FAMILY_NAME', v_family, now(), now())
        ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
      END IF;
      PERFORM public.recalculate_caller_id_consensus_v3(v_hash);
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_new_consensus TEXT;
    v_new_score REAL;
    v_is_owner BOOLEAN := FALSE;
BEGIN
    -- 1. Check if contributor is the owner
    SELECT (phone_hmac = p_phone_hash) INTO v_is_owner
    FROM public.profiles
    WHERE id = v_user_id;

    -- 2. Save unique contribution
    INSERT INTO public.caller_id_contributions (user_id, phone_hash, contributed_name)
    VALUES (v_user_id, p_phone_hash, p_name)
    ON CONFLICT (user_id, phone_hash) DO UPDATE
    SET contributed_name = EXCLUDED.contributed_name;

    -- 3. Calculate Winner
    IF v_is_owner THEN
        v_new_consensus := p_name;
        v_new_score := 1.0;
    ELSE
        -- Priority to owner if they ever contributed
        SELECT c.contributed_name INTO v_new_consensus
        FROM public.caller_id_contributions c
        JOIN public.profiles p ON c.user_id = p.id
        WHERE c.phone_hash = p_phone_hash AND p.phone_hmac = p_phone_hash
        LIMIT 1;

        IF v_new_consensus IS NOT NULL THEN
            v_new_score := 1.0;
            v_is_owner := TRUE;
        ELSE
            -- Majority rule for community
            SELECT name, score INTO v_new_consensus, v_new_score
            FROM (
                SELECT contributed_name as name, LEAST(0.9, COUNT(*)::REAL / 5.0) as score
                FROM public.caller_id_contributions
                WHERE phone_hash = p_phone_hash
                GROUP BY contributed_name
                ORDER BY COUNT(*) DESC
                LIMIT 1
            ) sub;
        END IF;
    END IF;

    -- 4. Sync to master identities
    INSERT INTO public.caller_id_identities (phone_hash, display_name, confidence_score, is_verified_profile, last_updated)
    VALUES (p_phone_hash, v_new_consensus, v_new_score, v_is_owner, now())
    ON CONFLICT (phone_hash) DO UPDATE
    SET display_name = EXCLUDED.display_name,
        confidence_score = EXCLUDED.confidence_score,
        is_verified_profile = EXCLUDED.is_verified_profile,
        last_updated = now();
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text" DEFAULT NULL::"text", "p_family_name" "text" DEFAULT NULL::"text", "p_nickname" "text" DEFAULT NULL::"text", "p_business_name" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  IF p_first_name IS NOT NULL AND p_first_name != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'FIRST_NAME', p_first_name, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  IF p_family_name IS NOT NULL AND p_family_name != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'FAMILY_NAME', p_family_name, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  IF p_nickname IS NOT NULL AND p_nickname != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'NICKNAME', p_nickname, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  IF p_business_name IS NOT NULL AND p_business_name != '' THEN
    INSERT INTO public.caller_contributions VALUES (auth.uid(), p_phone_hash, 'BUSINESS', p_business_name, now(), now())
    ON CONFLICT (contributor_user_id, phone_hash, field_type, candidate_value) DO UPDATE SET updated_at = now();
  END IF;
  PERFORM public.recalculate_caller_id_consensus_v3(p_phone_hash);
END;
$$;


ALTER FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
    new_count INTEGER;
    current_status TEXT;
    file_owner TEXT;
    file_path TEXT;
    category TEXT;
BEGIN
    SELECT status, owner_id::TEXT, storage_path
    INTO current_status, file_owner, file_path
    FROM public.files
    WHERE id = target_file_id;

    IF current_status <> 'ACTIVE' THEN
        RETURN;
    END IF;

    category := split_part(file_path, '/', 2);

    UPDATE public.files
    SET reference_count = reference_count - 1
    WHERE id = target_file_id
    RETURNING reference_count INTO new_count;

    IF new_count <= 0 THEN
        UPDATE public.files
        SET status = 'TRASH',
            archived_at = now(),
            scheduled_purge_at = now() + INTERVAL '30 days',
            original_bucket = 'keeftalk-private',
            original_path = file_path,
            original_category = category
        WHERE id = target_file_id;

        INSERT INTO public.storage_lifecycle_queue (file_id, user_id, action)
        VALUES (target_file_id, file_owner, 'MOVE_TO_TRASH');
    END IF;
END;
$$;


ALTER FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_balance NUMERIC(18, 6);
    v_pricing_id UUID;
BEGIN
    -- Select current active pricing version
    SELECT id INTO v_pricing_id FROM public.billing_pricing WHERE is_active = TRUE LIMIT 1;

    -- Lock prepaid balance row for atomic update
    SELECT prepaid_balance INTO v_balance
    FROM public.billing_balances
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        -- Auto-initialize balance record if missing
        INSERT INTO public.billing_balances (user_id, prepaid_balance)
        VALUES (p_user_id, 0.000000);
        v_balance := 0.000000;
    END IF;

    IF v_balance < p_amount THEN
        -- Insufficient prepaid balance
        RETURN FALSE;
    END IF;

    -- Deduct balance atomically
    UPDATE public.billing_balances
    SET prepaid_balance = prepaid_balance - p_amount,
        updated_at = now()
    WHERE user_id = p_user_id;

    -- Record immutable financial ledger entry
    INSERT INTO public.billing_ledger (
        user_id,
        transaction_type,
        base_amount,
        maintenance_amount,
        margin_amount,
        total_amount,
        pricing_version_id,
        description,
        idempotency_key
    ) VALUES (
        p_user_id,
        'USAGE_CHARGE',
        p_amount * 0.83, -- Base cost component
        p_amount * 0.12, -- 12% maintenance allocation
        p_amount * 0.05, -- 5% founder margin
        p_amount,
        v_pricing_id,
        p_description,
        p_idempotency_key
    ) ON CONFLICT (idempotency_key) DO NOTHING;

    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_expired_messages"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  DELETE FROM public.messages
  WHERE id IN (
    SELECT m.id 
    FROM public.messages m
    JOIN public.chats c ON m.chat_id = c.id
    WHERE c.auto_delete_timer IS NOT NULL
    AND (EXTRACT(EPOCH FROM NOW()) * 1000) > (m.timestamp + c.auto_delete_timer)
  );
END;
$$;


ALTER FUNCTION "public"."delete_expired_messages"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sender_id TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Get message info with explicit type handling
    SELECT sender_id::text, created_at INTO v_sender_id, v_created_at
    FROM public.messages
    WHERE id::text = p_message_id;

    -- 1. Authorization: Only sender can delete for everyone
    IF v_sender_id != auth.uid()::text THEN
        RAISE EXCEPTION 'Unauthorized: Only the sender can delete for everyone.';
    END IF;

    -- 2. Time Window: 10 minutes
    IF v_created_at < now() - INTERVAL '10 minutes' THEN
        RAISE EXCEPTION 'Delete for everyone window expired (10 minutes).';
    END IF;

    -- Update message status
    UPDATE public.messages
    SET
        deleted_at = now(),
        ciphertext = NULL, -- Scrub encrypted content
        nonce = NULL,
        content = '[Deleted]' -- Generic placeholder
    WHERE id::text = p_message_id;

    -- Cleanup attachments associated with this message
    -- Note: reference count cleanup is handled by application logic or triggers if implemented
END;
$$;


ALTER FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer DEFAULT 2) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sender_id TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Get message info with explicit type handling
    SELECT sender_id::text, created_at INTO v_sender_id, v_created_at
    FROM public.messages
    WHERE id::text = p_message_id;

    -- 1. Authorization: Only sender can edit
    IF v_sender_id != auth.uid()::text THEN
        RAISE EXCEPTION 'Unauthorized: Only the sender can edit this message.';
    END IF;

    -- 2. Time Window: 100 minutes
    IF v_created_at < now() - INTERVAL '100 minutes' THEN
        RAISE EXCEPTION 'Edit window expired (100 minutes).';
    END IF;

    -- 3. Check if already deleted
    IF EXISTS (SELECT 1 FROM public.messages WHERE id::text = p_message_id AND deleted_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Cannot edit a deleted message.';
    END IF;

    -- Update message
    UPDATE public.messages
    SET
        ciphertext = p_ciphertext,
        nonce = p_nonce,
        crypto_version = p_crypto_version,
        edited_at = now(),
        content = '[Edited]' -- Generic placeholder for UI until decrypted
    WHERE id::text = p_message_id;
END;
$$;


ALTER FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_name_change_cooldown"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Check if full_name is being updated
    IF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
        IF OLD.last_name_change_at IS NOT NULL AND OLD.last_name_change_at > (now() - INTERVAL '90 days') THEN
            RAISE EXCEPTION 'Name can only be changed once every 90 days. Next available change: %',
                (OLD.last_name_change_at + INTERVAL '90 days');
        END IF;
        NEW.last_name_change_at = now();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_name_change_cooldown"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text" DEFAULT 'PRO'::"text", "p_plan_type" "text" DEFAULT 'PRO_MONTHLY'::"text", "p_storage_limit" bigint DEFAULT '536870912000'::bigint, "p_feature_keys" "text"[] DEFAULT NULL::"text"[], "p_max_uses" integer DEFAULT 1, "p_expires_in_days" integer DEFAULT NULL::integer) RETURNS TABLE("generated_code" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    i INT;
    v_random_code TEXT;
    v_expiry TIMESTAMPTZ := NULL;
BEGIN
    IF p_expires_in_days IS NOT NULL THEN
        v_expiry := now() + (p_expires_in_days || ' days')::INTERVAL;
    END IF;

    FOR i IN 1..p_count LOOP
        v_random_code := p_prefix || '-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4)) || '-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4));
        
        INSERT INTO public.redeem_codes (
            code, type, plan_type, storage_limit, feature_keys, max_uses, expires_at
        ) VALUES (
            v_random_code, p_type, p_plan_type, p_storage_limit, p_feature_keys, p_max_uses, v_expiry
        ) ON CONFLICT (code) DO NOTHING;

        generated_code := v_random_code;
        RETURN NEXT;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_active_first_contact_policy"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    policy_val JSONB;
BEGIN
    SELECT value INTO policy_val FROM public.app_config WHERE key = 'first_contact_policy';
    RETURN COALESCE(policy_val, '{}'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_active_first_contact_policy"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    view_count BIGINT;
    click_count BIGINT;
    link_open_count BIGINT;
BEGIN
    -- Check if caller is official
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_official = TRUE) THEN
        RAISE EXCEPTION 'Unauthorized.';
    END IF;

    SELECT count(*) INTO view_count FROM public.official_broadcast_actions WHERE broadcast_id = p_broadcast_id AND action_type = 'VIEW';
    SELECT count(*) INTO click_count FROM public.official_broadcast_actions WHERE broadcast_id = p_broadcast_id AND action_type = 'CLICK';
    SELECT count(*) INTO link_open_count FROM public.official_broadcast_actions WHERE broadcast_id = p_broadcast_id AND action_type = 'LINK_OPEN';

    RETURN jsonb_build_object(
        'views', view_count,
        'clicks', click_count,
        'link_opens', link_open_count
    );
END;
$$;


ALTER FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_caller_id_pepper"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
    -- Returns your custom backend salt/pepper string. 
    -- Replace 'Keeftalk_Privacy_Shield_2026' with your production environment variable if needed.
    return 'Keeftalk_Privacy_Shield_2026';
end;
$$;


ALTER FUNCTION "public"."get_caller_id_pepper"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."get_connection_paths"("target_user_id" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
BEGIN
    RETURN (
        WITH RECURSIVE bfs_paths(user_id, depth, path) AS (
            SELECT p.id, 1, ARRAY[p.id]
            FROM public.profiles p
            WHERE public.is_social_connected(viewer_id, p.id)
          UNION ALL
            SELECT p_target.id, depth + 1, bp.path || p_target.id
            FROM public.profiles p_target
            JOIN bfs_paths bp ON public.is_social_connected(bp.user_id, p_target.id)
            JOIN public.user_privacy_settings privacy ON bp.user_id::text = privacy.user_id::text
            WHERE depth < 4
            AND (
                privacy.connections_visibility = 'EVERYONE'
                OR (privacy.connections_visibility = 'CONTACTS' AND public.is_social_connected(bp.user_id, viewer_id))
            )
            AND NOT p_target.id = ANY(bp.path)
        )
        SELECT COALESCE(jsonb_agg(masked_path), '[]'::jsonb)
        FROM (
            SELECT
                (
                    SELECT jsonb_agg(
                        CASE
                            WHEN node_id = target_id THEN node_id::text
                            WHEN EXISTS (SELECT 1 FROM public.user_privacy_settings WHERE user_id::text = node_id::text AND connections_visibility = 'NOBODY') THEN 'masked'
                            ELSE node_id::text
                        END
                    )
                    FROM unnest(path) AS node_id
                ) as masked_path
            FROM bfs_paths
            WHERE user_id = target_id
            LIMIT 3
        ) t
    );
END;
$$;


ALTER FUNCTION "public"."get_connection_paths"("target_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_chat_ids"() RETURNS TABLE("chat_id" "uuid")
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT chat_id FROM public.chat_members WHERE user_id = auth.uid();
$$;


ALTER FUNCTION "public"."get_my_chat_ids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_chats"() RETURNS TABLE("chat_id" "uuid")
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT chat_id FROM public.chat_members WHERE user_id = auth.uid();
$$;


ALTER FUNCTION "public"."get_my_chats"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    found_chat_id UUID;
BEGIN
    SELECT cm1.chat_id INTO found_chat_id
    FROM public.chat_members cm1
    JOIN public.chat_members cm2 ON cm1.chat_id = cm2.chat_id
    JOIN public.chats c ON c.id = cm1.chat_id
    WHERE c.type = 'ONE_TO_ONE'
      AND cm1.user_id = auth.uid()
      AND cm2.user_id = other_user_id;

    IF found_chat_id IS NOT NULL THEN
        RETURN found_chat_id;
    END IF;

    INSERT INTO public.chats(type)
    VALUES ('ONE_TO_ONE')
    RETURNING id INTO found_chat_id;

    INSERT INTO public.chat_members(chat_id, user_id)
    VALUES
        (found_chat_id, auth.uid()),
        (found_chat_id, other_user_id);

    RETURN found_chat_id;
END;
$$;


ALTER FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    found_chat_id UUID;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();

    -- Check for existing AI chat for this user
    SELECT c.id INTO found_chat_id
    FROM public.chats c
    JOIN public.chat_members cm ON c.id = cm.chat_id
    WHERE c.type = 'AI'
    AND cm.user_id = current_user_id
    LIMIT 1;

    IF found_chat_id IS NOT NULL THEN
        RETURN found_chat_id::text;
    END IF;

    -- Create new chat
    found_chat_id := gen_random_uuid();

    INSERT INTO public.chats (id, name, type, last_message_text)
    VALUES (found_chat_id, 'AI Assistant', 'AI', 'Hello! I am your AI assistant.');

    -- Add user as member
    INSERT INTO public.chat_members (chat_id, user_id)
    VALUES (found_chat_id, current_user_id);

    RETURN found_chat_id::text;
END;
$$;


ALTER FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_official_chat"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    official_user_id UUID := 'd9693526-d85e-48e5-ac83-88da31dfcbec'::uuid;
    found_chat_id UUID;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    -- Ensure profile is marked official
    UPDATE public.profiles SET is_official = TRUE WHERE id = official_user_id;

    -- Check for existing Official chat container for this user
    SELECT c.id INTO found_chat_id
    FROM public.chats c
    JOIN public.chat_members cm ON c.id = cm.chat_id
    WHERE c.type = 'OFFICIAL'
    AND cm.user_id = current_user_id
    LIMIT 1;

    IF found_chat_id IS NOT NULL THEN
        RETURN found_chat_id::text;
    END IF;

    -- Create new chat container
    found_chat_id := gen_random_uuid();

    INSERT INTO public.chats (id, name, type, last_message_text, avatar_url)
    VALUES (found_chat_id, 'Keeftalk', 'OFFICIAL', 'Welcome to Keeftalk ?', NULL);

    -- Add user as member
    INSERT INTO public.chat_members (chat_id, user_id)
    VALUES (found_chat_id, current_user_id);

    RETURN found_chat_id::text;
END;
$$;


ALTER FUNCTION "public"."get_or_create_official_chat"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_relationship_summary"("target_user_id" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
    result_distance INT := NULL;
    mutual_count INT := 0;
    mutual_previews JSONB := '[]'::jsonb;
    shortest_path_count INT := 0;
    density_label TEXT := 'LOW';
    strength_label TEXT := 'Inactive';
    strength_val FLOAT := 0.0;
    nudge_count INT := 0;
BEGIN
    -- 0. Self check
    IF viewer_id = target_id THEN
        RETURN jsonb_build_object('distance', 0, 'mutualCount', 0, 'nudgesReceived', 0, 'strengthLabel', 'Very strong');
    END IF;

    -- 0.1 Fetch Nudge Count
    SELECT nudges_received INTO nudge_count FROM public.profiles WHERE id = target_id;

    -- 1. Distance 1 (Direct connection)
    IF public.is_social_connected(viewer_id, target_id) THEN
        result_distance := 1;
        shortest_path_count := 1;
    END IF;

    -- 2. BFS for Distance 2-4
    IF result_distance IS NULL THEN
        WITH RECURSIVE bfs(user_id, depth, first_hop) AS (
            SELECT p.id, 1, p.id
            FROM public.profiles p
            WHERE public.is_social_connected(viewer_id, p.id)
            AND NOT EXISTS (SELECT 1 FROM public.blocked_users WHERE blocker_id::uuid = viewer_id AND blocked_id = p.id)
          UNION ALL
            SELECT p_target.id, depth + 1, bfs.first_hop
            FROM public.profiles p_target
            JOIN bfs ON public.is_social_connected(bfs.user_id, p_target.id)
            JOIN public.user_privacy_settings privacy ON bfs.user_id::text = privacy.user_id::text
            WHERE depth < 4
            AND (
                privacy.connections_visibility = 'EVERYONE'
                OR (privacy.connections_visibility = 'CONTACTS' AND public.is_social_connected(bfs.user_id, viewer_id))
            )
            AND NOT EXISTS (SELECT 1 FROM public.blocked_users WHERE blocker_id::uuid = bfs.user_id AND blocked_id = p_target.id)
        )
        SELECT
            MIN(depth),
            COUNT(DISTINCT first_hop)
        INTO result_distance, shortest_path_count
        FROM bfs
        WHERE user_id = target_id;
    END IF;

    -- 3. Mutual Connections Count
    SELECT
        COUNT(*),
        COALESCE(jsonb_agg(user_id::text) FILTER (WHERE row_num <= 3), '[]'::jsonb)
    INTO mutual_count, mutual_previews
    FROM (
        SELECT p.id as user_id, ROW_NUMBER() OVER() as row_num
        FROM public.profiles p
        WHERE public.is_social_connected(viewer_id, p.id)
        AND public.is_social_connected(target_id, p.id)
        AND NOT EXISTS (SELECT 1 FROM public.blocked_users WHERE blocker_id::uuid = viewer_id AND blocked_id = p.id)
    ) t;

    -- 4. Density & Strength
    IF shortest_path_count >= 3 OR mutual_count >= 6 THEN density_label := 'HIGH';
    ELSIF shortest_path_count >= 2 OR mutual_count >= 3 THEN density_label := 'MEDIUM';
    END IF;

    SELECT strength_score INTO strength_val FROM public.relationship_intelligence WHERE user_a = viewer_id AND user_b = target_id;
    IF strength_val >= 0.8 THEN strength_label := 'Very strong';
    ELSIF strength_val >= 0.5 THEN strength_label := 'Strong';
    ELSIF strength_val >= 0.2 THEN strength_label := 'Moderate';
    ELSIF strength_val > 0.0 THEN strength_label := 'Weak';
    END IF;

    RETURN jsonb_build_object(
        'distance', result_distance,
        'mutualCount', COALESCE(mutual_count, 0),
        'mutualPreviewIds', mutual_previews,
        'densityLabel', density_label,
        'strengthLabel', strength_label,
        'nudgesReceived', COALESCE(nudge_count, 0)
    );
END;
$$;


ALTER FUNCTION "public"."get_relationship_summary"("target_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_entitlements"("p_user_id" "text") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id uuid;
    v_sub record;
BEGIN
    v_user_id := p_user_id::uuid;
    SELECT plan, storage_limit_gb, hd_upload_enabled, priority_features_enabled, max_file_size_mb
    INTO v_sub
    FROM public.user_subscriptions
    WHERE user_id = v_user_id;
    IF NOT FOUND THEN
        RETURN json_build_object('plan', 'free', 'storage_limit_gb', 1);
    END IF;
    RETURN json_build_object('plan', v_sub.plan, 'storage_limit_gb', v_sub.storage_limit_gb);
END;
$$;


ALTER FUNCTION "public"."get_user_entitlements"("p_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") RETURNS TABLE("plan" "text", "storage_usage_bytes" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.plan, 
        s.storage_usage_bytes
    FROM public.user_subscriptions s
    WHERE s.user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_app_customization_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_app_customization_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_heartbeat"("uid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.user_presence (user_id, last_seen, is_online)
    VALUES (uid, NOW(), TRUE)
    ON CONFLICT (user_id)
    DO UPDATE SET last_seen = NOW(), is_online = TRUE;
END;
$$;


ALTER FUNCTION "public"."handle_heartbeat"("uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_message_sync_update"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.chats
    SET 
        last_message_text = NEW.content,
        last_message_time_ms = NEW.timestamp,
        last_message_sender_id = NEW.sender_id,
        last_message_status = NEW.status
    WHERE id = NEW.chat_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_message_sync_update"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- We call the Edge Function named 'send-message-notification'
  -- We pass the new message data as the payload
  -- replace 'YOUR_SUPABASE_PROJECT_ID' and 'YOUR_ANON_KEY' or use vault
  PERFORM
    net.http_post(
      url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-message-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || 'YOUR_SERVICE_ROLE_KEY'
      ),
      body := jsonb_build_object('record', row_to_json(NEW))
    );
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_message"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_message_sync"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.chats
  SET 
    last_message_text = CASE 
      WHEN NEW.type = 'TEXT' THEN NEW.content 
      ELSE '[' || NEW.type || ']' 
    END,
    last_message_time = NEW.created_at,
    last_message_status = NEW.status,
    last_message_sender_id = NEW.sender_id
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_message_sync"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_profile_privacy"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.user_privacy_settings (user_id) VALUES (NEW.id) ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_profile_privacy"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, email)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'username', 'user_' || substring(new.id::text from 1 for 8)),
    COALESCE(new.raw_user_meta_data->>'full_name', 'New User'),
    new.email
  );
  RETURN new;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (id, email, username, full_name, phone, country, country_code, phone_verified)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NULLIF(NEW.raw_user_meta_data->>'username', ''), 'user_' || substr(NEW.id::text, 1, 8)),
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'phone',
      NEW.raw_user_meta_data->>'country',
      NEW.raw_user_meta_data->>'country_code',
      FALSE
    )
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      username = COALESCE(NULLIF(public.profiles.username, ''), EXCLUDED.username),
      full_name = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
      phone = COALESCE(NULLIF(public.profiles.phone, ''), EXCLUDED.phone),
      country = COALESCE(NULLIF(public.profiles.country, ''), EXCLUDED.country),
      country_code = COALESCE(NULLIF(public.profiles.country_code, ''), EXCLUDED.country_code);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'handle_new_user_profile warning for user %: %', NEW.id, SQLERRM;
  END;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user_settings"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.user_chat_settings (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user_settings"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_profile_phone_hmac"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_pepper TEXT;
BEGIN
    SELECT value INTO v_pepper FROM public.caller_id_config WHERE key = 'current_pepper';
    
    IF NEW.phone IS NOT NULL AND NEW.phone != '' THEN
        NEW.phone_hmac := trim(from encode(hmac(NEW.phone::bytea, v_pepper::bytea, 'sha256'), 'base64'));
    ELSE
        NEW.phone_hmac := NULL;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_profile_phone_hmac"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_profile_view_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    viewer_name TEXT;
    owner_enabled BOOLEAN;
    viewer_enabled BOOLEAN;
BEGIN
    SELECT profile_view_history_enabled INTO owner_enabled
    FROM public.user_privacy_settings
    WHERE user_id = NEW.viewed_id;

    SELECT profile_view_history_enabled INTO viewer_enabled
    FROM public.user_privacy_settings
    WHERE user_id = NEW.viewer_id;

    IF COALESCE(owner_enabled, false) AND COALESCE(viewer_enabled, false) THEN
        SELECT full_name INTO viewer_name
        FROM public.profiles
        WHERE id = NEW.viewer_id;

        INSERT INTO public.notifications (user_id, type, title, message, data)
        VALUES (
            NEW.viewed_id,
            'PROFILE_VIEW',
            'Profile View',
            COALESCE(viewer_name, 'Someone') || ' viewed your profile',
            jsonb_build_object('viewer_id', NEW.viewer_id)
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_profile_view_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_security_event_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.notifications (user_id, type, priority, title, message, data)
    VALUES (
        NEW.user_id,
        'SYSTEM',
        'HIGH',
        'Security Alert',
        NEW.description,
        jsonb_build_object('event_type', NEW.event_type, 'device_id', NEW.device_id)
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_security_event_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_team_member_upgrade"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- If the email ends in @keeftalk.com, set as official and upgrade plan
    IF public.is_keeftalk_employee(NEW.email) THEN
        NEW.is_official := TRUE;
        NEW.plan_type := 'OFFICIAL';
        NEW.storage_limit := 109951162777600; -- 100TB
        NEW.is_verified := TRUE; -- Immediate verified badge
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_team_member_upgrade"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_visibility_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_visibility_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.files
    SET reference_count = reference_count + 1,
        status = 'ACTIVE',
        deleted_at = NULL
    WHERE id = target_file_id
    AND (
        owner_id::text = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM public.message_attachment ma
            JOIN public.messages m ON ma.message_id = m.id
            JOIN public.chat_members cm ON m.chat_id = cm.chat_id
            WHERE ma.file_id = target_file_id
            AND cm.user_id::text = auth.uid()::text
        )
        OR EXISTS (
            SELECT 1 FROM public.vault_items vi
            WHERE vi.file_id = target_file_id
            AND vi.user_id::text = auth.uid()::text
        )
    );
END;
$$;


ALTER FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_import_progress"("import_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.vault_share_imports
    SET processed_items = processed_items + 1,
        updated_at = now()
    WHERE id = import_id;
END;
$$;


ALTER FUNCTION "public"."increment_import_progress"("import_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_profile_view_count"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Increment the views_count for the user being viewed
    -- NEW.viewed_id refers to the ID in the profile_views table
    UPDATE public.profiles
    SET views_count = views_count + 1
    WHERE id::text = NEW.viewed_id::text;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_profile_view_count"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."increment_story_like"("p_story_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.stories SET likes_count = likes_count + 1 WHERE id = p_story_id;
END;
$$;


ALTER FUNCTION "public"."increment_story_like"("p_story_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_story_view"("p_story_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.stories SET viewrs = viewrs + 1 WHERE id = p_story_id;
END;
$$;


ALTER FUNCTION "public"."increment_story_view"("p_story_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."initialize_user_customization"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.user_app_customization (
        user_id, 
        onboarding_completed, 
        enabled_modules, 
        bottom_nav_tabs, 
        enabled_fab_actions
    )
    VALUES (
        NEW.id, 
        FALSE, 
        ARRAY['CHATS', 'CALLS', 'SMS', 'AGENDA', 'NOTES', 'EMAIL', 'VAULT', 'BOOKS', 'BROWSER'],
        ARRAY['CHATS', 'SMS', 'VAULT', 'BOOKS'],
        ARRAY['NEW_CHAT', 'NEW_GROUP', 'QR', 'AI', 'DISPLAY', 'MY_BOOKS']
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."initialize_user_customization"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."internal_base32_decode"("p_base32" "text") RETURNS "bytea"
    LANGUAGE "plpgsql" IMMUTABLE SECURITY DEFINER
    AS $$
DECLARE
    v_base32 TEXT := upper(p_base32);
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    v_bits TEXT := '';
    v_char CHAR;
    v_val INT;
    i INT;
    v_byte_count INT;
    v_bytes BYTEA := '\x'::bytea;
    v_byte_val INT;
BEGIN
    FOR i IN 1..length(v_base32) LOOP
        v_char := substr(v_base32, i, 1);
        IF v_char = '=' THEN
            EXIT;
        END IF;
        v_val := position(v_char IN v_chars) - 1;
        IF v_val < 0 THEN
            CONTINUE;
        END IF;
        -- Append 5 bits
        v_bits := v_bits || lpad(to_hex(v_val)::bit(5)::text, 5, '0');
    END LOOP;

    v_byte_count := length(v_bits) / 8;
    FOR i IN 1..v_byte_count LOOP
        v_byte_val := (substr(v_bits, (i - 1) * 8 + 1, 8)::bit(8))::INT;
        v_bytes := v_bytes || set_byte('\x00'::bytea, 0, v_byte_val);
    END LOOP;

    RETURN v_bytes;
END;
$$;


ALTER FUNCTION "public"."internal_base32_decode"("p_base32" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone DEFAULT "now"()) RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE SECURITY DEFINER
    AS $$
DECLARE
    v_key BYTEA;
    v_time_step BIGINT;
    v_msg BYTEA := '\x0000000000000000'::bytea;
    v_hmac BYTEA;
    v_offset INT;
    v_part1 INT;
    v_part2 INT;
    v_part3 INT;
    v_part4 INT;
    v_binary INT;
    v_otp INT;
    i INT;
BEGIN
    v_key := public.internal_base32_decode(p_secret_base32);
    v_time_step := floor(extract(epoch from p_timestamp) / 30)::BIGINT;

    -- Encode BIGINT v_time_step into 8-byte big-endian bytea
    FOR i IN 0..7 LOOP
        v_msg := set_byte(v_msg, 7 - i, ((v_time_step >> (i * 8)) & 255)::INT);
    END LOOP;

    v_hmac := hmac(v_msg, v_key, 'sha1');
    v_offset := (get_byte(v_hmac, length(v_hmac) - 1) & 15);

    v_part1 := (get_byte(v_hmac, v_offset) & 127);
    v_part2 := (get_byte(v_hmac, v_offset + 1) & 255);
    v_part3 := (get_byte(v_hmac, v_offset + 2) & 255);
    v_part4 := (get_byte(v_hmac, v_offset + 3) & 255);

    v_binary := (v_part1 << 24) | (v_part2 << 16) | (v_part3 << 8) | v_part4;
    v_otp := v_binary % 1000000;

    RETURN lpad(v_otp::text, 6, '0');
END;
$$;


ALTER FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."internal_random_base32_secret"("p_length" integer DEFAULT 32) RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    v_result TEXT := '';
    i INT;
    v_rand INT;
BEGIN
    FOR i IN 1..p_length LOOP
        v_rand := floor(random() * 32)::INT + 1;
        v_result := v_result || substr(v_chars, v_rand, 1);
    END LOOP;
    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."internal_random_base32_secret"("p_length" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_now TIMESTAMPTZ := now();
    v_t0 TIMESTAMPTZ := v_now - INTERVAL '30 seconds';
    v_t1 TIMESTAMPTZ := v_now;
    v_t2 TIMESTAMPTZ := v_now + INTERVAL '30 seconds';
BEGIN
    IF p_code IS NULL OR length(trim(p_code)) != 6 THEN
        RETURN FALSE;
    END IF;

    IF public.internal_compute_totp(p_secret_base32, v_t1) = trim(p_code) THEN
        RETURN TRUE;
    END IF;
    IF public.internal_compute_totp(p_secret_base32, v_t0) = trim(p_code) THEN
        RETURN TRUE;
    END IF;
    IF public.internal_compute_totp(p_secret_base32, v_t2) = trim(p_code) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$;


ALTER FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members
    WHERE chat_id = p_chat_id
    AND user_id = auth.uid()
    AND role = 'admin'
  );
END;
$$;


ALTER FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_chat_member"("target_chat_id" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members
    WHERE chat_id = target_chat_id
    AND user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."is_chat_member"("target_chat_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_chat_member"("c_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.chat_members
        WHERE chat_id = c_id
        AND user_id = auth.uid()
    );
END;
$$;


ALTER FUNCTION "public"."is_chat_member"("c_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT (
    p_user_id = p_sender_id OR
    p_user_id = p_receiver_id OR
    (p_group_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM public.group_members
      WHERE group_members.group_id = p_group_id
      AND group_members.user_id = p_user_id
    ))
  );
$$;


ALTER FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_email_verified"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  confirmed_at TIMESTAMPTZ;
BEGIN
  SELECT email_confirmed_at INTO confirmed_at
  FROM auth.users
  WHERE id = auth.uid();

  RETURN confirmed_at IS NOT NULL;
END;
$$;


ALTER FUNCTION "public"."is_email_verified"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_group_member"("p_group_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.group_members
        WHERE group_id = p_group_id AND user_id = auth.uid()
    );
END;
$$;


ALTER FUNCTION "public"."is_group_member"("p_group_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_members.group_id = p_group_id
    AND group_members.user_id = p_user_id
  );
$$;


ALTER FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_keeftalk_employee"("p_email" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
BEGIN
    RETURN p_email ILIKE '%@keeftalk.com';
END;
$$;


ALTER FUNCTION "public"."is_keeftalk_employee"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_member_of"("p_chat_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.chat_members
    WHERE chat_id = p_chat_id
    AND user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."is_member_of"("p_chat_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Override: Official users are connected to everyone
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id IN (user_id_a, user_id_b) AND is_official = TRUE) THEN
        RETURN TRUE;
    END IF;

    RETURN EXISTS (
        -- Check Contacts
        SELECT 1 FROM public.contacts c
        JOIN public.profiles p ON c.phone = p.phone
        WHERE c.owner_id::uuid = user_id_a AND p.id = user_id_b
        UNION ALL
        -- Check Chat Members
        SELECT 1 FROM public.chat_members cm1
        JOIN public.chat_members cm2 ON cm1.chat_id = cm2.chat_id AND cm1.user_id != cm2.user_id
        JOIN public.chats c ON cm1.chat_id = c.id
        WHERE cm1.user_id::uuid = user_id_a AND cm2.user_id::uuid = user_id_b
        AND c.type = 'ONE_TO_ONE'
    );
END;
$$;


ALTER FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb" DEFAULT '[]'::"jsonb", "p_screens" "jsonb" DEFAULT '[]'::"jsonb", "p_chats" "jsonb" DEFAULT '[]'::"jsonb", "p_media" "jsonb" DEFAULT '[]'::"jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    -- Security: Ensure user is authenticated
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Sessions
    IF jsonb_array_length(p_sessions) > 0 THEN
        INSERT INTO public.user_sessions (id, user_id, device_id, session_start, session_end, duration_seconds, platform)
        SELECT
            (val->>'id')::uuid,
            v_user_id, -- Force current authenticated user ID
            val->>'device_id',
            (val->>'session_start')::timestamp with time zone,
            (val->>'session_end')::timestamp with time zone,
            (val->>'duration_seconds')::integer,
            COALESCE(val->>'platform', 'android')
        FROM jsonb_array_elements(p_sessions) AS val
        WHERE (val->>'user_id')::uuid = v_user_id -- Security filter
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Screens
    IF jsonb_array_length(p_screens) > 0 THEN
        INSERT INTO public.screen_events (id, user_id, screen_name, entered_at, exited_at, duration_seconds, chat_id)
        SELECT
            (val->>'id')::uuid,
            v_user_id,
            val->>'screen_name',
            (val->>'entered_at')::timestamp with time zone,
            (val->>'exited_at')::timestamp with time zone,
            (val->>'duration_seconds')::integer,
            val->>'chat_id'
        FROM jsonb_array_elements(p_screens) AS val
        WHERE (val->>'user_id')::uuid = v_user_id
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Chats
    IF jsonb_array_length(p_chats) > 0 THEN
        INSERT INTO public.chat_events (id, user_id, chat_id, event_type, timestamp, metadata)
        SELECT
            (val->>'id')::uuid,
            v_user_id,
            val->>'chat_id',
            val->>'event_type',
            (val->>'timestamp')::timestamp with time zone,
            COALESCE(val->'metadata', '{}'::jsonb)
        FROM jsonb_array_elements(p_chats) AS val
        WHERE (val->>'user_id')::uuid = v_user_id
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Media
    IF jsonb_array_length(p_media) > 0 THEN
        INSERT INTO public.media_events (id, user_id, type, action, size_bytes, timestamp)
        SELECT
            (val->>'id')::uuid,
            v_user_id,
            val->>'type',
            val->>'action',
            (val->>'size_bytes')::bigint,
            (val->>'timestamp')::timestamp with time zone
        FROM jsonb_array_elements(p_media) AS val
        WHERE (val->>'user_id')::uuid = v_user_id
        ON CONFLICT (id) DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) RETURNS TABLE("number" "text", "display_name" "text", "identity_type" "text", "is_verified" boolean, "spam_score" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    WITH input_numbers AS (
        SELECT UNNEST(phone_numbers) as num
    ),
    verified_identities AS (
        -- Priority 1: Verified Keeftalk Accounts
        -- Only if user has caller_id_enabled = TRUE
        SELECT
            p.phone as num,
            p.full_name as name,
            'VERIFIED' as type,
            TRUE as verified
        FROM public.profiles p
        WHERE p.phone = ANY(phone_numbers)
          AND p.caller_id_enabled = TRUE
          AND (p.phone_visibility = 'EVERYONE' OR p.phone_visibility IS NULL)
    ),
    community_identities AS (
        -- Priority 2: Community data
        -- Select name with highest contribution count, requiring at least 1 contribution
        SELECT DISTINCT ON (phone_identifier)
            phone_identifier as num,
            cn.name,
            'COMMUNITY' as type,
            FALSE as verified
        FROM public.caller_id_names cn
        WHERE cn.phone_identifier = ANY(phone_numbers)
          AND cn.contribution_count >= 1
        ORDER BY phone_identifier, contribution_count DESC
    )
    SELECT
        in_n.num,
        COALESCE(vi.name, ci.name) as display_name,
        COALESCE(vi.type, ci.type, 'UNKNOWN') as identity_type,
        COALESCE(vi.verified, FALSE) as is_verified,
        COALESCE(sr.spam_score, 0.0) as spam_score
    FROM input_numbers in_n
    LEFT JOIN verified_identities vi ON in_n.num = vi.num
    LEFT JOIN community_identities ci ON in_n.num = ci.num
    LEFT JOIN public.caller_id_spam_reports sr ON in_n.num = sr.phone_identifier;
END;
$$;


ALTER FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) RETURNS TABLE("p_hash" "text", "display_name" "text", "identity_type" "text", "is_verified" boolean, "spam_score" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update Quota
    UPDATE public.caller_id_quotas
    SET daily_lookups = CASE WHEN last_lookup_date < CURRENT_DATE THEN 1 ELSE daily_lookups + 1 END,
        last_lookup_date = CURRENT_DATE
    WHERE user_id = auth.uid();

    RETURN QUERY
    WITH input_hashes AS (
        SELECT UNNEST(phone_hashes) as h
    ),
    verified_identities AS (
        SELECT 
            p.phone_hmac as h,
            p.full_name as name,
            'VERIFIED' as type,
            TRUE as verified
        FROM public.profiles p
        WHERE p.phone_hmac = ANY(phone_hashes)
          AND p.caller_id_enabled = TRUE
          AND (p.phone_visibility = 'EVERYONE' OR p.phone_visibility IS NULL)
    ),
    all_identities AS (
        SELECT 
            id.phone_hash as h,
            id.display_name as name,
            CASE WHEN id.is_verified_profile THEN 'VERIFIED' ELSE 'COMMUNITY' END as type,
            id.is_verified_profile as verified
        FROM public.caller_id_identities id
        WHERE id.phone_hash = ANY(phone_hashes)
    ),
    spam_signals AS (
        SELECT 
            sr.phone_hash as h,
            (COUNT(*)::REAL * 0.1) as score
        FROM public.caller_id_spam_reporters sr
        WHERE sr.phone_hash = ANY(phone_hashes)
        GROUP BY sr.phone_hash
    )
    SELECT
        in_h.h,
        COALESCE(vi.name, ai.name) as display_name,
        COALESCE(vi.type, ai.type, 'UNKNOWN') as identity_type,
        COALESCE(vi.verified, ai.verified, FALSE) as is_verified,
        COALESCE(ss.score, 0.0)::REAL as spam_score
    FROM input_hashes in_h
    LEFT JOIN verified_identities vi ON in_h.h = vi.h
    LEFT JOIN all_identities ai ON in_h.h = ai.h
    LEFT JOIN spam_signals ss ON in_h.h = ss.h;
END;
$$;


ALTER FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) RETURNS TABLE("p_hash" "text", "identity_data" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.caller_id_quotas
  SET daily_lookups = CASE WHEN last_lookup_date < CURRENT_DATE THEN 1 ELSE daily_lookups + 1 END,
      last_lookup_date = CURRENT_DATE
  WHERE user_id = auth.uid();

  RETURN QUERY
  WITH input_hashes AS (SELECT UNNEST(phone_hashes) AS h), identities AS (
    SELECT id.phone_hash AS h, jsonb_build_object(
      'firstName', id.first_name, 'familyName', id.family_name,
      'firstNameConfidence', id.first_name_confidence,
      'familyNameConfidence', id.family_name_confidence,
      'verifiedFirstName', id.verified_first_name,
      'verifiedFamilyName', id.verified_family_name,
      'isVerified', id.is_verified_profile, 'businessName', id.business_name,
      'businessConfidence', id.business_confidence, 'spamScore', id.spam_score,
      'nicknames', (SELECT jsonb_agg(jsonb_build_object('nickname', n.nickname, 'confidence', n.confidence))
                    FROM public.caller_nicknames n
                    WHERE n.phone_hash = id.phone_hash AND n.confidence > 0.2)
    ) AS data
    FROM public.caller_identities id WHERE id.phone_hash = ANY(phone_hashes)
  )
  SELECT in_h.h, COALESCE(i.data, '{}'::jsonb)
  FROM input_hashes in_h LEFT JOIN identities i ON in_h.h = i.h;
END;
$$;


ALTER FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_new_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update the last_message info on the chat record automatically
    UPDATE public.chats 
    SET 
        last_message_text = CASE 
            WHEN NEW.type = 'TEXT' THEN NEW.content 
            ELSE '[' || NEW.type || ']' 
        END,
        last_message_time = NEW.created_at,
        last_message_status = NEW.status,
        last_message_sender_id = NEW.sender_id
    WHERE id = NEW.chat_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_new_message"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_security_event"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  active_session RECORD;
  anon_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyOTUzNDMsImV4cCI6MjA5Nzg3MTM0M30.vu5Zga2iX37NlDV9v0IgQp_PjDNWJmmqqhrvLJ9Un9E';
BEGIN
  -- Iterate through ALL active sessions for this user
  FOR active_session IN
    SELECT fcm_token FROM public.user_sessions
    WHERE user_id = NEW.user_id AND fcm_token IS NOT NULL
  LOOP
    PERFORM net.http_post(
      url := 'https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || anon_key
      ),
      body := jsonb_build_object(
        'to', active_session.fcm_token,
        'type', 'security_alert',
        'title', 'Security Alert',
        'body', COALESCE(NEW.description, 'A security event occurred on your account.'),
        'ip', NEW.ip_address,
        'city', NEW.city,
        'country', NEW.country
      )
    );
  END LOOP;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_security_event"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_session_revoked"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    PERFORM pg_notify(
        'session_revoked',
        json_build_object(
            'id', OLD.id,
            'user_id', OLD.user_id,
            'device_id', OLD.device_id
        )::text
    );
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."notify_session_revoked"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_message_update_relationship_strength"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    PERFORM public.calculate_relationship_strength(NEW.sender_id::text, cm.user_id::text)
    FROM public.chat_members cm
    JOIN public.chats c ON cm.chat_id = c.id
    WHERE cm.chat_id = NEW.chat_id
    AND cm.user_id::text != NEW.sender_id::text
    AND c.type = 'ONE_TO_ONE';

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_message_update_relationship_strength"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_official_message_sent"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    is_official_sender BOOLEAN;
    chat_type TEXT;
BEGIN
    -- Only promote if sender has is_official flag
    SELECT is_official INTO is_official_sender FROM public.profiles WHERE id = NEW.sender_id::uuid;
    -- chat_id might be stored as TEXT in messages but is UUID in chats
    SELECT type INTO chat_type FROM public.chats WHERE id = NEW.chat_id::uuid;

    IF is_official_sender AND chat_type = 'OFFICIAL' THEN
        INSERT INTO public.broadcasts (id, sender_id, content, type, published_at)
        VALUES (
            NEW.id::uuid,
            NEW.sender_id::uuid,
            jsonb_build_object('en', NEW.content),
            NEW.type,
            now()
        ) ON CONFLICT (id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_official_message_sent"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_vault_import_started"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.vault_share_invites
    SET use_count = use_count + 1
    WHERE id = NEW.share_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_vault_import_started"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."protect_parental_controls"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- If a supervisor is set and the current user is NOT that supervisor,
    -- prevent them from changing the parental_controls field.
    IF (OLD.parental_controls->>'supervisor_id' IS NOT NULL
        AND OLD.parental_controls->>'supervisor_id' != (auth.uid())::text) THEN

        -- Silently preserve the OLD parental_controls to prevent RLS/Trigger violations
        -- while allowing other settings to be updated.
        NEW.parental_controls = OLD.parental_controls;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."protect_parental_controls"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_best_first TEXT; v_first_conf REAL; v_best_family TEXT; v_family_conf REAL;
  v_best_business TEXT; v_business_conf REAL; v_is_verified BOOLEAN := FALSE;
  v_v_first TEXT; v_v_family TEXT; v_spam_score REAL := 0.0;
BEGIN
  SELECT caller_id_enabled, split_part(full_name, ' ', 1), substring(full_name from position(' ' in full_name) + 1)
  INTO v_is_verified, v_v_first, v_v_family
  FROM public.profiles
  WHERE phone_hmac = p_phone_hash AND (phone_visibility = 'EVERYONE' OR phone_visibility IS NULL)
  LIMIT 1;

  SELECT candidate_value, COUNT(*)::REAL / 10.0 INTO v_best_first, v_first_conf
  FROM public.caller_contributions WHERE phone_hash = p_phone_hash AND field_type = 'FIRST_NAME'
  GROUP BY candidate_value ORDER BY COUNT(*) DESC LIMIT 1;

  SELECT candidate_value, COUNT(*)::REAL / 10.0 INTO v_best_family, v_family_conf
  FROM public.caller_contributions WHERE phone_hash = p_phone_hash AND field_type = 'FAMILY_NAME'
  GROUP BY candidate_value ORDER BY COUNT(*) DESC LIMIT 1;

  SELECT candidate_value, COUNT(*)::REAL / 5.0 INTO v_best_business, v_business_conf
  FROM public.caller_contributions WHERE phone_hash = p_phone_hash AND field_type = 'BUSINESS'
  GROUP BY candidate_value ORDER BY COUNT(*) DESC LIMIT 1;

  SELECT COALESCE(COUNT(*)::REAL * 0.1, 0.0) INTO v_spam_score
  FROM public.caller_spam_reporters WHERE phone_hash = p_phone_hash;

  INSERT INTO public.caller_identities (
    phone_hash, first_name, family_name, first_name_confidence, family_name_confidence,
    is_verified_profile, verified_first_name, verified_family_name,
    business_name, business_confidence, spam_score, last_updated
  ) VALUES (
    p_phone_hash, v_best_first, v_best_family, COALESCE(v_first_conf, 0.0), COALESCE(v_family_conf, 0.0),
    COALESCE(v_is_verified, FALSE), v_v_first, v_v_family,
    v_best_business, COALESCE(v_business_conf, 0.0), COALESCE(v_spam_score, 0.0), now()
  ) ON CONFLICT (phone_hash) DO UPDATE SET
    first_name = EXCLUDED.first_name, family_name = EXCLUDED.family_name,
    first_name_confidence = EXCLUDED.first_name_confidence,
    family_name_confidence = EXCLUDED.family_name_confidence,
    is_verified_profile = EXCLUDED.is_verified_profile,
    verified_first_name = EXCLUDED.verified_first_name,
    verified_family_name = EXCLUDED.verified_family_name,
    business_name = EXCLUDED.business_name,
    business_confidence = EXCLUDED.business_confidence,
    spam_score = EXCLUDED.spam_score, last_updated = now();

  DELETE FROM public.caller_nicknames WHERE phone_hash = p_phone_hash;
  INSERT INTO public.caller_nicknames (phone_hash, nickname, confidence)
  SELECT phone_hash, candidate_value, COUNT(*)::REAL / 10.0
  FROM public.caller_contributions
  WHERE phone_hash = p_phone_hash AND field_type = 'NICKNAME'
  GROUP BY phone_hash, candidate_value;
END;
$$;


ALTER FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."redeem_code"("p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_code_rec RECORD;
    v_fkey TEXT;
    v_already_redeemed BOOLEAN;
BEGIN
    -- 1. Verify user authentication
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Authentication required. Please log in.');
    END IF;

    -- 2. Lookup code (case-insensitive)
    SELECT * INTO v_code_rec
    FROM public.redeem_codes
    WHERE LOWER(code) = LOWER(TRIM(p_code));

    IF v_code_rec.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid redemption code.');
    END IF;

    IF NOT v_code_rec.is_active THEN
        RETURN jsonb_build_object('success', false, 'error', 'This redemption code has been deactivated.');
    END IF;

    IF v_code_rec.expires_at IS NOT NULL AND v_code_rec.expires_at < now() THEN
        RETURN jsonb_build_object('success', false, 'error', 'This redemption code has expired.');
    END IF;

    IF v_code_rec.max_uses > 0 AND v_code_rec.used_count >= v_code_rec.max_uses THEN
        RETURN jsonb_build_object('success', false, 'error', 'This redemption code has reached its maximum usage limit.');
    END IF;

    -- 3. Check if user already redeemed this code
    SELECT EXISTS (
        SELECT 1 FROM public.redeem_history
        WHERE user_id = v_user_id AND code_id = v_code_rec.id
    ) INTO v_already_redeemed;

    IF v_already_redeemed THEN
        RETURN jsonb_build_object('success', false, 'error', 'You have already redeemed this code.');
    END IF;

    -- 4. Apply Benefits (Subscription / Storage / Entitlements)
    IF v_code_rec.type = 'PRO' OR v_code_rec.type = 'FAMILY' OR v_code_rec.plan_type IS NOT NULL THEN
        UPDATE public.profiles
        SET plan_type = COALESCE(v_code_rec.plan_type, 'PRO_MONTHLY')::public.subscription_plan,
            storage_limit = COALESCE(v_code_rec.storage_limit, 536870912000)
        WHERE id = v_user_id;

        INSERT INTO public.subscriptions (user_id, plan, status, order_id, purchase_token)
        VALUES (
            v_user_id,
            COALESCE(v_code_rec.plan_type, 'PRO_MONTHLY')::public.subscription_plan,
            'active',
            'REDEEM_' || v_code_rec.code,
            'REDEEM_TOKEN_' || v_code_rec.code || '_' || v_user_id
        )
        ON CONFLICT (purchase_token) DO UPDATE SET status = 'active', updated_at = now();
    END IF;

    -- Insert Feature Entitlements
    IF v_code_rec.feature_keys IS NOT NULL AND array_length(v_code_rec.feature_keys, 1) > 0 THEN
        FOREACH v_fkey IN ARRAY v_code_rec.feature_keys LOOP
            INSERT INTO public.user_feature_entitlements (user_id, feature_id, enabled, status)
            VALUES (v_user_id, v_fkey, TRUE, 'ACTIVE')
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;

    -- 5. Record History & Update Usage Count
    INSERT INTO public.redeem_history (user_id, code_id, code)
    VALUES (v_user_id, v_code_rec.id, v_code_rec.code);

    UPDATE public.redeem_codes
    SET used_count = used_count + 1
    WHERE id = v_code_rec.id;

    -- 6. Return Success Response
    RETURN jsonb_build_object(
        'success', true,
        'type', v_code_rec.type,
        'title', 'Redemption Successful!',
        'message', 'Code redeemed successfully. Your account capabilities and feature cloud syncs have been updated.',
        'plan_type', v_code_rec.plan_type
    );
END;
$$;


ALTER FUNCTION "public"."redeem_code"("p_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- 1. Lock the key for update and check redemption count again
    -- This prevents race conditions
    IF NOT EXISTS (
        SELECT 1 FROM public.subscription_keys
        WHERE id = p_key_id AND redemption_count < max_redemptions
        FOR UPDATE
    ) THEN
        RAISE EXCEPTION 'Key has reached maximum redemptions';
    END IF;

    -- 2. Increment redemption count
    UPDATE public.subscription_keys
    SET redemption_count = redemption_count + 1
    WHERE id = p_key_id;

    -- 3. Record redemption
    INSERT INTO public.subscription_key_redemptions (
        key_id, user_id, redeemed_at, entitlement_start, entitlement_expiration, resulting_plan, resulting_storage
    ) VALUES (
        p_key_id, p_user_id, now(), p_entitlement_start, p_entitlement_expiration, p_plan, p_storage_bytes
    );

    -- 4. Create Entitlement
    INSERT INTO public.user_entitlements (
        user_id, source, plan, storage_bytes, starts_at, expires_at, lifetime, source_key_id, status
    ) VALUES (
        p_user_id, 'redeemed_key', p_plan, p_storage_bytes, p_entitlement_start, p_entitlement_expiration, p_lifetime, p_key_id, 'active'
    );

END;
$$;


ALTER FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reply_to_message_request"("p_request_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    req RECORD;
    viewer_id UUID := auth.uid();
BEGIN
    SELECT * INTO req FROM public.message_requests WHERE id::text = p_request_id;
    IF req.id IS NULL THEN
        RAISE EXCEPTION 'Message request not found';
    END IF;

    IF req.recipient_id != viewer_id THEN
        RAISE EXCEPTION 'Only recipient can reply to message request';
    END IF;

    -- Update request status
    UPDATE public.message_requests
    SET recipient_replied = true,
        status = 'converted_to_chat',
        updated_at = now()
    WHERE id = req.id;

    -- Ensure chat is marked or registered as normal chat if needed
    -- (The conversation already exists in chats table)
END;
$$;


ALTER FUNCTION "public"."reply_to_message_request"("p_request_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.caller_id_spam_reports (phone_identifier, report_count, spam_score, last_updated)
    VALUES (p_phone_identifier, 1, 0.1, now())
    ON CONFLICT (phone_identifier) DO UPDATE
    SET report_count = caller_id_spam_reports.report_count + 1,
        spam_score = LEAST(1.0, caller_id_spam_reports.spam_score + 0.1),
        last_updated = now();
END;
$$;


ALTER FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  INSERT INTO public.caller_spam_reporters (user_id, phone_hash)
  VALUES (auth.uid(), p_phone_hash) ON CONFLICT (user_id, phone_hash) DO NOTHING;
  PERFORM public.recalculate_caller_id_consensus_v3(p_phone_hash);
END;
$$;


ALTER FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rls_auto_enable"() RETURNS "event_trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."rls_auto_enable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_begin_totp_enrollment"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_email TEXT;
    v_secret TEXT;
    v_qr_uri TEXT;
    v_factor_id UUID;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT email INTO v_email FROM auth.users WHERE id = v_user_id;
    IF v_email IS NULL THEN
        v_email := v_user_id::text;
    END IF;

    v_secret := public.internal_random_base32_secret(32);
    v_qr_uri := 'otpauth://totp/Keeftalk:' || v_email || '?secret=' || v_secret || '&issuer=Keeftalk';

    INSERT INTO public.user_2fa_factors (user_id, factor_type, status, totp_secret, created_at)
    VALUES (v_user_id, 'totp', 'PENDING', v_secret, now())
    ON CONFLICT (user_id, factor_type) DO UPDATE
    SET status = 'PENDING', totp_secret = EXCLUDED.totp_secret, created_at = now()
    RETURNING id INTO v_factor_id;

    RETURN jsonb_build_object(
        'factor_id', v_factor_id,
        'secret', v_secret,
        'qr_code_uri', v_qr_uri
    );
END;
$$;


ALTER FUNCTION "public"."rpc_begin_totp_enrollment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_factors JSONB;
    v_pref TEXT;
    v_enabled BOOLEAN;
    v_challenge_id UUID;
BEGIN
    SELECT two_factor_enabled, preferred_2fa_method
    INTO v_enabled, v_pref
    FROM public.user_security_settings
    WHERE user_id = p_user_id;

    IF v_enabled IS NOT TRUE THEN
        RETURN jsonb_build_object('requires_2fa', false);
    END IF;

    SELECT COALESCE(jsonb_agg(factor_type), '[]'::jsonb)
    INTO v_factors
    FROM public.user_2fa_factors
    WHERE user_id = p_user_id AND status = 'ACTIVE';

    IF jsonb_array_length(v_factors) = 0 THEN
        RETURN jsonb_build_object('requires_2fa', false);
    END IF;

    INSERT INTO public.two_factor_login_challenges (
        user_id, status, allowed_factors, preferred_factor, expires_at
    ) VALUES (
        p_user_id, 'PENDING', v_factors, v_pref, now() + INTERVAL '10 minutes'
    ) RETURNING id INTO v_challenge_id;

    RETURN jsonb_build_object(
        'requires_2fa', true,
        'login_challenge_id', v_challenge_id,
        'user_id', p_user_id,
        'allowed_factors', v_factors,
        'preferred_factor', v_pref
    );
END;
$$;


ALTER FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_remaining_active INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    DELETE FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND factor_type = p_factor_type;

    SELECT count(*) INTO v_remaining_active
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND status = 'ACTIVE';

    IF v_remaining_active = 0 THEN
        UPDATE public.user_security_settings
        SET two_factor_enabled = FALSE, preferred_2fa_method = NULL
        WHERE user_id = v_user_id;

        DELETE FROM public.user_2fa_backup_codes WHERE user_id = v_user_id;
    END IF;

    RETURN jsonb_build_object('success', true, 'remaining_factors', v_remaining_active);
END;
$$;


ALTER FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_generate_backup_codes"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excluding ambiguous characters O,0,I,1
    v_code TEXT;
    v_hash TEXT;
    v_plain_codes JSONB := '[]'::jsonb;
    i INT;
    j INT;
    v_part1 TEXT;
    v_part2 TEXT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Delete old backup codes for this user
    DELETE FROM public.user_2fa_backup_codes WHERE user_id = v_user_id;

    FOR i IN 1..10 LOOP
        v_part1 := '';
        v_part2 := '';
        FOR j IN 1..4 LOOP
            v_part1 := v_part1 || substr(v_chars, floor(random() * 32)::INT + 1, 1);
            v_part2 := v_part2 || substr(v_chars, floor(random() * 32)::INT + 1, 1);
        END LOOP;
        v_code := v_part1 || '-' || v_part2;
        v_hash := encode(digest(v_code, 'sha256'), 'hex');

        INSERT INTO public.user_2fa_backup_codes (user_id, code_hash, used, created_at)
        VALUES (v_user_id, v_hash, FALSE, now());

        v_plain_codes := v_plain_codes || to_jsonb(v_code);
    END LOOP;

    RETURN jsonb_build_object(
        'success', true,
        'backup_codes', v_plain_codes
    );
END;
$$;


ALTER FUNCTION "public"."rpc_generate_backup_codes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_get_2fa_status"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_factors JSONB;
    v_has_backup BOOLEAN;
    v_pref TEXT;
    v_enabled BOOLEAN := FALSE;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', id,
            'factor_type', factor_type,
            'status', status,
            'verified_destination', verified_destination,
            'is_preferred', is_preferred,
            'created_at', extract(epoch from created_at)::BIGINT * 1000,
            'last_used_at', CASE WHEN last_used_at IS NOT NULL THEN extract(epoch from last_used_at)::BIGINT * 1000 ELSE NULL END
        )
    ), '[]'::jsonb)
    INTO v_factors
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND status = 'ACTIVE';

    SELECT EXISTS(
        SELECT 1 FROM public.user_2fa_backup_codes
        WHERE user_id = v_user_id AND used = FALSE
    ) INTO v_has_backup;

    SELECT two_factor_enabled, preferred_2fa_method
    INTO v_enabled, v_pref
    FROM public.user_security_settings
    WHERE user_id = v_user_id;

    RETURN jsonb_build_object(
        'two_factor_enabled', COALESCE(v_enabled, FALSE),
        'preferred_method', v_pref,
        'has_backup_codes', v_has_backup,
        'active_factors', v_factors
    );
END;
$$;


ALTER FUNCTION "public"."rpc_get_2fa_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text" DEFAULT 'ENROLLMENT'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_email TEXT;
    v_masked TEXT;
    v_code TEXT;
    v_code_hash TEXT;
    v_challenge_id UUID;
    v_cooldown TIMESTAMPTZ;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT email INTO v_email FROM auth.users WHERE id = v_user_id;
    IF v_email IS NULL OR v_email = '' THEN
        RAISE EXCEPTION 'No verified email found for this user account.';
    END IF;

    -- Mask email e.g. m***@example.com
    v_masked := overlay(v_email placing '***' from 2 for position('@' in v_email) - 2);

    -- Rate limiting / resend cooldown check
    SELECT resend_cooldown_until INTO v_cooldown
    FROM public.two_factor_otp_challenges
    WHERE user_id = v_user_id AND factor_type = 'email' AND consumed_at IS NULL
    ORDER BY created_at DESC LIMIT 1;

    IF v_cooldown IS NOT NULL AND v_cooldown > now() THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Please wait before requesting a new code.',
            'cooldown_seconds', ceil(extract(epoch from (v_cooldown - now())))
        );
    END IF;

    -- Generate cryptographically secure 6-digit OTP code
    v_code := lpad(floor(100000 + random() * 900000)::text, 6, '0');
    v_code_hash := encode(digest(v_code, 'sha256'), 'hex');

    -- Invalidate existing unconsumed challenges
    UPDATE public.two_factor_otp_challenges
    SET consumed_at = now()
    WHERE user_id = v_user_id AND factor_type = 'email' AND consumed_at IS NULL;

    INSERT INTO public.two_factor_otp_challenges (
        user_id, factor_type, purpose, otp_hash, destination_masked, expires_at, resend_cooldown_until
    ) VALUES (
        v_user_id, 'email', p_purpose, v_code_hash, v_masked, now() + INTERVAL '10 minutes', now() + INTERVAL '60 seconds'
    ) RETURNING id INTO v_challenge_id;

    RETURN jsonb_build_object(
        'success', true,
        'challenge_id', v_challenge_id,
        'masked_destination', v_masked,
        'cooldown_seconds', 60
    );
END;
$$;


ALTER FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text" DEFAULT 'ENROLLMENT'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_phone TEXT;
    v_masked TEXT;
    v_code TEXT;
    v_code_hash TEXT;
    v_challenge_id UUID;
    v_cooldown TIMESTAMPTZ;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT phone INTO v_phone FROM public.profiles WHERE id = v_user_id::text;
    IF v_phone IS NULL OR v_phone = '' THEN
        SELECT phone INTO v_phone FROM auth.users WHERE id = v_user_id;
    END IF;

    IF v_phone IS NULL OR v_phone = '' THEN
        RAISE EXCEPTION 'No phone number registered on profile.';
    END IF;

    -- Mask phone number e.g. +1 *** *** 1234
    IF length(v_phone) > 6 THEN
        v_masked := substr(v_phone, 1, 3) || ' *** *** ' || substr(v_phone, length(v_phone) - 3);
    ELSE
        v_masked := '***' || substr(v_phone, length(v_phone) - 2);
    END IF;

    -- Rate limiting / resend cooldown check
    SELECT resend_cooldown_until INTO v_cooldown
    FROM public.two_factor_otp_challenges
    WHERE user_id = v_user_id AND factor_type = 'sms' AND consumed_at IS NULL
    ORDER BY created_at DESC LIMIT 1;

    IF v_cooldown IS NOT NULL AND v_cooldown > now() THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Please wait before requesting a new SMS code.',
            'cooldown_seconds', ceil(extract(epoch from (v_cooldown - now())))
        );
    END IF;

    v_code := lpad(floor(100000 + random() * 900000)::text, 6, '0');
    v_code_hash := encode(digest(v_code, 'sha256'), 'hex');

    UPDATE public.two_factor_otp_challenges
    SET consumed_at = now()
    WHERE user_id = v_user_id AND factor_type = 'sms' AND consumed_at IS NULL;

    INSERT INTO public.two_factor_otp_challenges (
        user_id, factor_type, purpose, otp_hash, destination_masked, expires_at, resend_cooldown_until
    ) VALUES (
        v_user_id, 'sms', p_purpose, v_code_hash, v_masked, now() + INTERVAL '5 minutes', now() + INTERVAL '60 seconds'
    ) RETURNING id INTO v_challenge_id;

    RETURN jsonb_build_object(
        'success', true,
        'challenge_id', v_challenge_id,
        'masked_destination', v_masked,
        'cooldown_seconds', 60
    );
END;
$$;


ALTER FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_exists BOOLEAN;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT EXISTS(
        SELECT 1 FROM public.user_2fa_factors
        WHERE user_id = v_user_id AND factor_type = p_factor_type AND status = 'ACTIVE'
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN jsonb_build_object('success', false, 'message', 'Specified factor is not active.');
    END IF;

    UPDATE public.user_2fa_factors
    SET is_preferred = (factor_type = p_factor_type)
    WHERE user_id = v_user_id;

    UPDATE public.user_security_settings
    SET preferred_2fa_method = p_factor_type
    WHERE user_id = v_user_id;

    RETURN jsonb_build_object('success', true, 'preferred_method', p_factor_type);
END;
$$;


ALTER FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_challenge RECORD;
    v_secret TEXT;
    v_valid BOOLEAN := FALSE;
    v_code_hash TEXT;
    v_backup_rec RECORD;
    v_verification_token TEXT;
BEGIN
    SELECT * INTO v_challenge
    FROM public.two_factor_login_challenges
    WHERE id = p_login_challenge_id;

    IF v_challenge IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid 2FA login challenge.');
    END IF;

    IF v_challenge.status != 'PENDING' THEN
        RETURN jsonb_build_object('success', false, 'message', '2FA login challenge is no longer valid.');
    END IF;

    IF v_challenge.expires_at < now() THEN
        UPDATE public.two_factor_login_challenges SET status = 'EXPIRED' WHERE id = p_login_challenge_id;
        RETURN jsonb_build_object('success', false, 'message', '2FA login challenge has expired.');
    END IF;

    -- Handle Factor Types
    IF p_factor_type = 'totp' THEN
        SELECT totp_secret INTO v_secret
        FROM public.user_2fa_factors
        WHERE user_id = v_challenge.user_id AND factor_type = 'totp' AND status = 'ACTIVE';

        IF v_secret IS NULL THEN
            RETURN jsonb_build_object('success', false, 'message', 'Authenticator app factor is not active.');
        END IF;

        v_valid := public.internal_verify_totp(v_secret, p_code);

    ELSIF p_factor_type IN ('email', 'sms') THEN
        -- Check recent unconsumed OTP challenge
        v_code_hash := encode(digest(trim(p_code), 'sha256'), 'hex');

        SELECT id INTO v_secret
        FROM public.two_factor_otp_challenges
        WHERE user_id = v_challenge.user_id
          AND factor_type = p_factor_type
          AND otp_hash = v_code_hash
          AND consumed_at IS NULL
          AND expires_at > now();

        IF v_secret IS NOT NULL THEN
            v_valid := TRUE;
            UPDATE public.two_factor_otp_challenges SET consumed_at = now() WHERE id = v_secret::UUID;
        END IF;

    ELSIF p_factor_type = 'backup_code' THEN
        v_code_hash := encode(digest(upper(trim(p_code)), 'sha256'), 'hex');

        SELECT * INTO v_backup_rec
        FROM public.user_2fa_backup_codes
        WHERE user_id = v_challenge.user_id AND code_hash = v_code_hash AND used = FALSE;

        IF v_backup_rec IS NOT NULL THEN
            v_valid := TRUE;
            UPDATE public.user_2fa_backup_codes
            SET used = TRUE, used_at = now()
            WHERE id = v_backup_rec.id;
        END IF;
    END IF;

    IF NOT v_valid THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid verification code.');
    END IF;

    -- Issue short-lived verification token to finalize login
    v_verification_token := encode(digest(random()::text || now()::text, 'sha256'), 'hex');

    UPDATE public.two_factor_login_challenges
    SET status = 'VERIFIED',
        verified_at = now(),
        verification_token = v_verification_token
    WHERE id = p_login_challenge_id;

    UPDATE public.user_2fa_factors
    SET last_used_at = now()
    WHERE user_id = v_challenge.user_id AND factor_type = p_factor_type;

    RETURN jsonb_build_object(
        'success', true,
        'verification_token', v_verification_token,
        'user_id', v_challenge.user_id
    );
END;
$$;


ALTER FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_challenge RECORD;
    v_input_hash TEXT;
    v_dest TEXT;
    v_active_count INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT * INTO v_challenge
    FROM public.two_factor_otp_challenges
    WHERE id = p_challenge_id AND user_id = v_user_id;

    IF v_challenge IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid or expired OTP challenge.');
    END IF;

    IF v_challenge.consumed_at IS NOT NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'This verification code has already been used.');
    END IF;

    IF v_challenge.expires_at < now() THEN
        RETURN jsonb_build_object('success', false, 'message', 'Verification code has expired. Request a new code.');
    END IF;

    IF v_challenge.attempt_count >= v_challenge.max_attempts THEN
        RETURN jsonb_build_object('success', false, 'message', 'Maximum verification attempts exceeded. Request a new code.');
    END IF;

    v_input_hash := encode(digest(trim(p_otp_code), 'sha256'), 'hex');

    IF v_challenge.otp_hash != v_input_hash THEN
        UPDATE public.two_factor_otp_challenges
        SET attempt_count = attempt_count + 1
        WHERE id = p_challenge_id;

        RETURN jsonb_build_object('success', false, 'message', 'Incorrect verification code.');
    END IF;

    -- Mark challenge as consumed
    UPDATE public.two_factor_otp_challenges
    SET consumed_at = now()
    WHERE id = p_challenge_id;

    -- If this was for ENROLLMENT, activate the factor
    IF v_challenge.purpose = 'ENROLLMENT' THEN
        SELECT count(*) INTO v_active_count
        FROM public.user_2fa_factors
        WHERE user_id = v_user_id AND status = 'ACTIVE';

        INSERT INTO public.user_2fa_factors (user_id, factor_type, status, verified_destination, is_preferred, created_at, last_used_at)
        VALUES (v_user_id, v_challenge.factor_type, 'ACTIVE', v_challenge.destination_masked, (v_active_count = 0), now(), now())
        ON CONFLICT (user_id, factor_type) DO UPDATE
        SET status = 'ACTIVE',
            verified_destination = EXCLUDED.verified_destination,
            last_used_at = now();

        UPDATE public.user_security_settings
        SET two_factor_enabled = TRUE,
            preferred_2fa_method = COALESCE(preferred_2fa_method, v_challenge.factor_type),
            updated_at = now()
        WHERE user_id = v_user_id;
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Verification successful.');
END;
$$;


ALTER FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_secret TEXT;
    v_valid BOOLEAN;
    v_active_count INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT totp_secret INTO v_secret
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND factor_type = 'totp';

    IF v_secret IS NULL THEN
        RAISE EXCEPTION 'TOTP enrollment has not been initialized.';
    END IF;

    v_valid := public.internal_verify_totp(v_secret, p_totp_code);
    IF NOT v_valid THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid 6-digit TOTP code. Check your authenticator app time sync.');
    END IF;

    -- Check if other active factors exist
    SELECT count(*) INTO v_active_count
    FROM public.user_2fa_factors
    WHERE user_id = v_user_id AND status = 'ACTIVE';

    UPDATE public.user_2fa_factors
    SET status = 'ACTIVE', last_used_at = now(), is_preferred = (v_active_count = 0)
    WHERE user_id = v_user_id AND factor_type = 'totp';

    -- Update overall security settings
    INSERT INTO public.user_security_settings (user_id, two_factor_enabled, preferred_2fa_method, updated_at)
    VALUES (v_user_id, TRUE, 'totp', now())
    ON CONFLICT (user_id) DO UPDATE
    SET two_factor_enabled = TRUE,
        preferred_2fa_method = COALESCE(user_security_settings.preferred_2fa_method, 'totp'),
        updated_at = now();

    RETURN jsonb_build_object('success', true, 'message', 'Authenticator app enabled successfully.');
END;
$$;


ALTER FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.notes 
    WHERE id = n_id AND owner_id = u_id
  );
$$;


ALTER FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_nudge"("target_user_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
    viewer_name TEXT;
BEGIN
    -- Increment nudge count on profile
    UPDATE public.profiles SET nudges_received = nudges_received + 1 WHERE id = target_id;
    
    -- Get viewer name for the notification
    SELECT COALESCE(full_name, username, 'Someone') INTO viewer_name FROM public.profiles WHERE id = viewer_id;
    
    -- Insert into internal notifications table
    INSERT INTO public.notifications (
        id, 
        user_id, 
        type, 
        priority, 
        title, 
        message, 
        created_at, 
        is_read, 
        source_id
    ) VALUES (
        gen_random_uuid(),
        target_id,
        'SYSTEM',
        'HIGH',
        'New Nudge!',
        viewer_name || ' nudged you.',
        now(),
        false,
        viewer_id::text
    );
END;
$$;


ALTER FUNCTION "public"."send_nudge"("target_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    viewer_id UUID := auth.uid();
    target_id UUID := target_user_id::uuid;
    viewer_name TEXT;
    existing_notif_id UUID;
    total_nudges INT;
BEGIN
    -- 1. Increment global nudge count on profile (if target exists)
    UPDATE public.profiles SET nudges_received = nudges_received + nudge_increment WHERE id = target_id;

    -- 2. Get viewer name with explicit fallback for NULL results
    SELECT COALESCE(full_name, username, 'Someone') INTO viewer_name FROM public.profiles WHERE id = viewer_id;

    -- Crucial: Ensure viewer_name is never null even if SELECT returns no rows
    IF viewer_name IS NULL THEN
        viewer_name := 'Someone';
    END IF;

    -- 3. Check for existing unread nudge from this sender
    SELECT id, nudge_count INTO existing_notif_id, total_nudges
    FROM public.notifications
    WHERE user_id = target_id
    AND source_id = viewer_id::text
    AND is_read = false
    AND type = 'NUDGE'
    LIMIT 1;

    IF existing_notif_id IS NOT NULL THEN
        -- Update existing notification
        UPDATE public.notifications
        SET nudge_count = nudge_count + nudge_increment,
            message = viewer_name || ' nudged you ' || (total_nudges + nudge_increment)::text || ' times.',
            created_at = now()
        WHERE id = existing_notif_id;
    ELSE
        -- Create new notification
        INSERT INTO public.notifications (
            id, user_id, type, priority, title, message, created_at, is_read, source_id, nudge_count
        ) VALUES (
            gen_random_uuid(),
            target_id,
            'NUDGE',
            'HIGH',
            'New Nudge!',
            CASE
                WHEN nudge_increment > 1 THEN viewer_name || ' nudged you ' || nudge_increment::text || ' times.'
                ELSE viewer_name || ' nudged you.'
            END,
            now(),
            false,
            viewer_id::text,
            nudge_increment
        );
    END IF;
END;
$$;


ALTER FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := p_user_id::uuid;
    UPDATE public.user_subscriptions
    SET plan = p_plan::public.user_plan,
        storage_limit_gb = CASE WHEN p_plan = 'pro' THEN 100 WHEN p_plan = 'plus' THEN 10 ELSE 1 END,
        updated_at = now()
    WHERE user_id = v_user_id;
END;
$$;


ALTER FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_subscriptions
    SET plan = p_plan
    WHERE user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_chat_last_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    UPDATE public.chats
    SET last_message_id = NEW.id,
        last_message_text = NEW.content,
        last_message_time = NEW.created_at,
        last_message_status = NEW.status,
        last_message_sender_id = NEW.sender_id,
        updated_at = now()
    WHERE id = NEW.chat_id;

  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE public.chats
    SET last_message_status = NEW.status,
        updated_at = now()
    WHERE id = NEW.chat_id
      AND last_message_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_chat_last_message"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_chat_status_from_pointers"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- For 1:1 chats, update the last_message_status based on the peer's pointer
    IF EXISTS (SELECT 1 FROM public.chats WHERE id = NEW.chat_id AND type = 'ONE_TO_ONE') THEN
        UPDATE public.chats
        SET last_message_status = CASE 
            WHEN NEW.last_read_message_id IS NOT NULL THEN 'SEEN'
            WHEN NEW.last_delivered_message_id IS NOT NULL THEN 'DELIVERED'
            ELSE last_message_status
        END
        WHERE id = NEW.chat_id 
        AND last_message_id IN (NEW.last_read_message_id, NEW.last_delivered_message_id);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_chat_status_from_pointers"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_family_member_benefits"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_owner_id UUID;
    owner_plan public.subscription_plan;
BEGIN
    -- If a new family member is added
    IF TG_OP = 'INSERT' THEN
        SELECT owner_id INTO f_owner_id FROM public.families WHERE id = NEW.family_id;
        SELECT plan_type INTO owner_plan FROM public.profiles WHERE id = f_owner_id;

        IF owner_plan = 'FAMILY_MONTHLY' THEN
            UPDATE public.profiles
            SET plan_type = 'PLUS_MONTHLY', -- Inherit Plus benefits
                storage_limit = 2199023255552, -- 2TB (Shared pool)
                family_id = NEW.family_id
            WHERE id = NEW.user_id;
        END IF;
    END IF;

    -- If a member is removed
    IF TG_OP = 'DELETE' THEN
        UPDATE public.profiles
        SET plan_type = 'FREE',
            storage_limit = 5368709120, -- 5GB
            storage_used = public.calculate_user_storage_usage(OLD.user_id),
            family_id = NULL,
            is_family_owner = FALSE -- Just in case
        WHERE id = OLD.user_id;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."sync_family_member_benefits"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_official_broadcasts"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID := auth.uid();
    official_chat_id UUID;
    official_user_id UUID := 'd9693526-d85e-48e5-ac83-88da31dfcbec'::uuid;
    user_lang TEXT;
    broadcast_rec RECORD;
BEGIN
    -- 1. Get user preferred language
    SELECT preferred_language INTO user_lang FROM public.profiles WHERE id = current_user_id;
    user_lang := COALESCE(user_lang, 'en');

    -- 2. Ensure official chat container is active
    SELECT get_or_create_official_chat()::UUID INTO official_chat_id;

    -- 3. Sync broadcasts
    FOR broadcast_rec IN
        SELECT * FROM public.broadcasts
        ORDER BY published_at ASC
    LOOP
        INSERT INTO public.messages (
            id, chat_id, sender_id, content, type, timestamp, status, ciphertext, crypto_version
        ) VALUES (
            broadcast_rec.id,
            official_chat_id,
            official_user_id, -- Force official sender
            COALESCE(broadcast_rec.content->>user_lang, broadcast_rec.content->>'en'),
            broadcast_rec.type,
            (extract(epoch from broadcast_rec.published_at) * 1000)::BIGINT,
            'SENT',
            NULL,
            0
        ) ON CONFLICT (id) DO UPDATE SET
            content = EXCLUDED.content,
            sender_id = EXCLUDED.sender_id;
    END LOOP;

    -- 4. Update sync state
    INSERT INTO public.user_broadcast_sync (user_id, last_synced_language, updated_at)
    VALUES (current_user_id, user_lang, now())
    ON CONFLICT (user_id) DO UPDATE SET
        last_synced_language = EXCLUDED.last_synced_language,
        updated_at = now();
END;
$$;


ALTER FUNCTION "public"."sync_official_broadcasts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
BEGIN
    -- 1. Update or Insert Subscription Record
    INSERT INTO public.subscriptions (user_id, plan, status, purchase_token, order_id, expiry_date, updated_at)
    VALUES (target_user_id::uuid, new_plan, new_status, new_purchase_token, new_order_id, new_expiry, now())
    ON CONFLICT (purchase_token) DO UPDATE SET
        status = EXCLUDED.status,
        expiry_date = EXCLUDED.expiry_date,
        updated_at = now();

    -- 2. Update Profile SSOT
    UPDATE public.profiles
    SET plan_type = new_plan,
        storage_limit = new_limit
    WHERE id = target_user_id;

    -- 3. If Family plan, ensure family record exists and link it
    IF new_plan = 'FAMILY_MONTHLY' THEN
        INSERT INTO public.families (owner_id)
        VALUES (target_user_id)
        ON CONFLICT (owner_id) DO NOTHING; -- Assuming owner_id UNIQUE for families if one owner per family

        SELECT id INTO f_id FROM public.families WHERE owner_id = target_user_id;

        -- Auto-add owner to their own family members if not present
        INSERT INTO public.family_members (family_id, user_id)
        VALUES (f_id, target_user_id)
        ON CONFLICT DO NOTHING;

        UPDATE public.profiles SET is_family_owner = TRUE, family_id = f_id WHERE id = target_user_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    f_id UUID;
BEGIN
    -- 1. Update or Insert Subscription Record
    INSERT INTO public.subscriptions (user_id, plan, status, purchase_token, order_id, expiry_date, updated_at)
    VALUES (target_user_id, new_plan, new_status, new_purchase_token, new_order_id, new_expiry, now())
    ON CONFLICT (purchase_token) DO UPDATE SET
        status = EXCLUDED.status,
        expiry_date = EXCLUDED.expiry_date,
        updated_at = now();

    -- 2. Update Profile SSOT
    UPDATE public.profiles
    SET plan_type = new_plan,
        storage_limit = new_limit
    WHERE id = target_user_id;

    -- 3. If Family plan, ensure family record exists and link it
    IF new_plan = 'FAMILY_MONTHLY' THEN
        INSERT INTO public.families (owner_id)
        VALUES (target_user_id)
        ON CONFLICT (owner_id) DO NOTHING; -- Assuming owner_id UNIQUE for families if one owner per family

        SELECT id INTO f_id FROM public.families WHERE owner_id = target_user_id;

        -- Auto-add owner to their own family members if not present
        INSERT INTO public.family_members (family_id, user_id)
        VALUES (f_id, target_user_id)
        ON CONFLICT DO NOTHING;

        UPDATE public.profiles SET is_family_owner = TRUE, family_id = f_id WHERE id = target_user_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog', 'public'
    AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
    END IF;
    IF p_epoch_day IS NULL OR p_feature_key IS NULL OR btrim(p_feature_key) = '' OR p_add_seconds IS NULL OR p_add_seconds <= 0 THEN
        RAISE EXCEPTION 'Invalid time tracking input' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.user_time_tracking (user_id, epoch_day, feature_key, duration_seconds, updated_at)
    VALUES (auth.uid(), p_epoch_day, p_feature_key, p_add_seconds, pg_catalog.now())
    ON CONFLICT (user_id, epoch_day, feature_key)
    DO UPDATE SET
        duration_seconds = public.user_time_tracking.duration_seconds + EXCLUDED.duration_seconds,
        updated_at = pg_catalog.now();
END;
$$;


ALTER FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF p_is_pinned THEN
        INSERT INTO public.pinned_messages (chat_id, message_id, pinned_by)
        VALUES (p_chat_id, p_message_id, auth.uid())
        ON CONFLICT (chat_id, message_id) DO NOTHING;
    ELSE
        DELETE FROM public.pinned_messages
        WHERE chat_id::text = p_chat_id::text 
        AND message_id::text = p_message_id::text;
    END IF;
END;
$$;


ALTER FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.official_broadcast_actions (broadcast_id, user_id, action_type, metadata)
    VALUES (p_broadcast_id, auth.uid(), p_action_type, p_metadata);
END;
$$;


ALTER FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_fcm_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  payload jsonb;
  -- Your project's anon key from AppModule.kt
  anon_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyOTUzNDMsImV4cCI6MjA5Nzg3MTM0M30.vu5Zga2iX37NlDV9v0IgQp_PjDNWJmmqqhrvLJ9Un9E';
BEGIN
  payload := jsonb_build_object(
    'table', TG_TABLE_NAME,
    'type', TG_OP,
    'record', row_to_json(NEW),
    'old_record', CASE WHEN TG_OP = 'UPDATE' THEN row_to_json(OLD) ELSE NULL END
  );

  -- Call the Supabase Edge Function asynchronously via pg_net
  PERFORM net.http_post(
    url := 'https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || anon_key
    ),
    body := payload
  );

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_fcm_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_chat_last_activity"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE public.chats
    SET last_activity_at = NEW.created_at
    WHERE id = NEW.chat_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_chat_last_activity"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
 BEGIN
     IF EXISTS (
         SELECT 1 FROM public.family_members 
         WHERE user_id = auth.uid() 
         AND member_id = target_user_id 
         AND included = true
     ) THEN
         INSERT INTO public.user_controls (user_id, supervisor_id, communication_restriction, content_restriction, usage_limit, updated_at)
         VALUES (target_user_id, auth.uid(), comm_rest, cont_rest, usage_lim, timezone('utc'::text, now()))
         ON CONFLICT (user_id, supervisor_id) DO UPDATE SET
             communication_restriction = comm_rest,
             content_restriction = cont_rest,
             usage_limit = usage_lim,
             updated_at = timezone('utc'::text, now());
     ELSE
         RAISE EXCEPTION 'Unauthorized: User is not a supervisor for this child.';
     END IF;
 END;
 $$;


ALTER FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_extension_install_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.store_extensions
    SET install_count = (
            SELECT COUNT(*) FROM public.store_installations WHERE extension_id = NEW.extension_id AND status = 'INSTALLED'
        ),
        updated_at = NOW()
    WHERE id = NEW.extension_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_extension_install_stats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_extension_rating_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.store_extensions
    SET rating_count = (
            SELECT COUNT(*) FROM public.store_ratings WHERE extension_id = COALESCE(NEW.extension_id, OLD.extension_id)
        ),
        rating_avg = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2) FROM public.store_ratings WHERE extension_id = COALESCE(NEW.extension_id, OLD.extension_id)
        ), 0.00),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.extension_id, OLD.extension_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_extension_rating_stats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_file_reference_count"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_file_id UUID;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        target_file_id := NEW.file_id;
        UPDATE public.files SET reference_count = reference_count + 1 WHERE id = target_file_id;
    ELSIF (TG_OP = 'DELETE') THEN
        target_file_id := OLD.file_id;
        UPDATE public.files SET reference_count = reference_count - 1 WHERE id = target_file_id;
    END IF;

    UPDATE public.files 
    SET status = CASE WHEN reference_count <= 0 THEN 'PENDING_DELETE' ELSE 'ACTIVE' END,
        deleted_at = CASE WHEN reference_count <= 0 THEN NOW() ELSE NULL END
    WHERE id = target_file_id;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_file_reference_count"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_profile_storage_usage"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_id TEXT;
    f_id UUID;
BEGIN
    target_id := COALESCE(NEW.owner_id, OLD.owner_id);

    -- Find if this user is in a family (Directly from profile)
    SELECT family_id INTO f_id FROM public.profiles WHERE id::text = target_id::text;

    IF f_id IS NOT NULL THEN
        -- Update all members of the family to keep their 'storage_used' in sync for the UI
        UPDATE public.profiles
        SET storage_used = public.calculate_user_storage_usage(target_id)
        WHERE family_id = f_id;
    ELSE
        -- Update only the user
        UPDATE public.profiles
        SET storage_used = public.calculate_user_storage_usage(target_id)
        WHERE id::text = target_id::text;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_profile_storage_usage"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := p_user_id::uuid;
    INSERT INTO public.user_storage (user_id, total_size_bytes) VALUES (v_user_id, 0) ON CONFLICT (user_id) DO NOTHING;
    UPDATE public.user_storage
    SET total_size_bytes = total_size_bytes + p_file_size,
        image_size_bytes = CASE WHEN p_file_type LIKE 'image/%' THEN image_size_bytes + p_file_size ELSE image_size_bytes END,
        video_size_bytes = CASE WHEN p_file_type LIKE 'video/%' THEN video_size_bytes + p_file_size ELSE video_size_bytes END,
        document_size_bytes = CASE WHEN p_file_type NOT LIKE 'image/%' AND p_file_type NOT LIKE 'video/%' THEN document_size_bytes + p_file_size ELSE document_size_bytes END,
        updated_at = now()
    WHERE user_id = v_user_id;
END;
$$;


ALTER FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_active_benefits"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_user_id UUID;
    best_plan public.subscription_plan;
    total_storage BIGINT;
    base_storage BIGINT := 5368709120; -- 5GB base
BEGIN
    target_user_id := COALESCE(NEW.user_id, OLD.user_id);

    -- 1. Find the "best" active plan
    -- Priority order: OFFICIAL > FAMILY > PRO > PLUS > FREE
    -- We'll use a CASE statement to rank them
    SELECT plan INTO best_plan
    FROM public.user_entitlements
    WHERE user_id = target_user_id
      AND status = 'active'
      AND (expires_at IS NULL OR expires_at > now())
    ORDER BY
        CASE plan
            WHEN 'OFFICIAL' THEN 5
            WHEN 'FAMILY_MONTHLY' THEN 4
            WHEN 'PRO_MONTHLY' THEN 3
            WHEN 'PLUS_YEARLY' THEN 2
            WHEN 'PLUS_MONTHLY' THEN 1
            ELSE 0
        END DESC,
        expires_at DESC NULLS FIRST
    LIMIT 1;

    IF best_plan IS NULL THEN
        best_plan := 'FREE';
    END IF;

    -- 2. Sum up storage (Base + Active Entitlements)
    -- Note: We might want to handle plan-included storage vs extra storage
    -- For simplicity here, we sum storage from all active entitlements that explicitly grant storage
    SELECT COALESCE(SUM(storage_bytes), 0) INTO total_storage
    FROM public.user_entitlements
    WHERE user_id = target_user_id
      AND status = 'active'
      AND (expires_at IS NULL OR expires_at > now());

    -- Update Profile
    UPDATE public.profiles
    SET plan_type = best_plan,
        storage_limit = base_storage + total_storage
    WHERE id = target_user_id;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_user_active_benefits"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."validate_background_media"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    total_count INTEGER;
    image_count INTEGER;
    video_count INTEGER;
BEGIN
    -- Check orientation and resolution: landscape only, min FHD (width >= height AND width >= 1080)
    IF NEW.width < NEW.height OR NEW.width < 1080 THEN
        RAISE EXCEPTION 'Background media must be landscape and at least FHD resolution (1080p).';
    END IF;

    -- Check video duration
    IF NEW.media_type = 'VIDEO' AND (NEW.duration_seconds IS NULL OR NEW.duration_seconds > 60 OR NEW.duration_seconds <= 0) THEN
        RAISE EXCEPTION 'Background video duration must be 60 seconds or less.';
    END IF;

    -- Check counts
    SELECT COUNT(*) INTO total_count FROM public.profile_background_media WHERE user_id = NEW.user_id AND id != NEW.id;
    IF total_count >= 5 THEN
        RAISE EXCEPTION 'Maximum 5 background media items allowed per profile.';
    END IF;

    IF NEW.media_type = 'IMAGE' THEN
        SELECT COUNT(*) INTO image_count FROM public.profile_background_media WHERE user_id = NEW.user_id AND media_type = 'IMAGE' AND id != NEW.id;
        IF image_count >= 4 THEN
            RAISE EXCEPTION 'Maximum 4 background images allowed per profile.';
        END IF;
    ELSIF NEW.media_type = 'VIDEO' THEN
        SELECT COUNT(*) INTO video_count FROM public.profile_background_media WHERE user_id = NEW.user_id AND media_type = 'VIDEO' AND id != NEW.id;
        IF video_count >= 1 THEN
            RAISE EXCEPTION 'Maximum 1 background video allowed per profile.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_background_media"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."BIN_DB" (
    "BIN" "text" NOT NULL,
    "Brand" "text",
    "Type" "text",
    "Category" "text",
    "Issuer" "text",
    "IssuerPhone" "text",
    "IssuerUrl" "text",
    "isoCode2" "text",
    "isoCode3" "text",
    "CountryName" "text"
);


ALTER TABLE "public"."BIN_DB" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."account_deletions" (
    "user_id" "text" NOT NULL,
    "requested_at" timestamp with time zone DEFAULT "now"(),
    "retention_until" timestamp with time zone DEFAULT ("now"() + '30 days'::interval),
    "status" "text" DEFAULT 'DELETION_REQUESTED'::"text",
    "cancelled_at" timestamp with time zone
);


ALTER TABLE "public"."account_deletions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."admin_users" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "role" "text" DEFAULT 'admin'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."admin_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."agenda_attachment" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "agenda_event_id" "uuid" NOT NULL,
    "file_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."agenda_attachment" REPLICA IDENTITY FULL;


ALTER TABLE "public"."agenda_attachment" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ai_chat_settings" (
    "chat_id" "text" NOT NULL,
    "user_id" "uuid",
    "provider_id" "text",
    "model_id" "text",
    "encrypted_system_prompt" "text",
    "prompt_iv" "text",
    "settings_json" "text" NOT NULL,
    "updated_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_chat_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ai_credentials" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "provider_id" "text" NOT NULL,
    "encrypted_key" "text" NOT NULL,
    "iv" "text" NOT NULL,
    "version" integer NOT NULL,
    "updated_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_credentials" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ai_memories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "encrypted_content" "text" NOT NULL,
    "iv" "text" NOT NULL,
    "scope" "text" NOT NULL,
    "chat_id" "text",
    "category" "text",
    "importance" integer DEFAULT 0,
    "created_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_memories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ai_provider_configs" (
    "id" "text" NOT NULL,
    "user_id" "uuid",
    "name" "text" NOT NULL,
    "type" "text" NOT NULL,
    "base_url" "text",
    "is_enabled" boolean DEFAULT true,
    "created_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint,
    "updated_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint
);


ALTER TABLE "public"."ai_provider_configs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."app_config" (
    "key" "text" NOT NULL,
    "value" "jsonb" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."app_config" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_audit_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "admin_id" "uuid",
    "action" "text" NOT NULL,
    "pricing_version_id" "uuid",
    "changes" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_audit_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_balances" (
    "user_id" "uuid" NOT NULL,
    "prepaid_balance" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "low_balance_threshold" numeric(18,6) DEFAULT 2.000000 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_balances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_invoices" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invoice_number" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "billing_period_start" timestamp with time zone NOT NULL,
    "billing_period_end" timestamp with time zone NOT NULL,
    "subtotal" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "maintenance_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "margin_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "total" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "status" "text" DEFAULT 'UNPAID'::"text" NOT NULL,
    "due_date" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_invoices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_ledger" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "transaction_type" "text" NOT NULL,
    "base_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "maintenance_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "margin_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "total_amount" numeric(18,6) DEFAULT 0.000000 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "pricing_version_id" "uuid",
    "description" "text",
    "idempotency_key" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_ledger" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "invoice_id" "uuid",
    "amount" numeric(18,6) NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "provider" "text" DEFAULT 'MANUAL'::"text" NOT NULL,
    "provider_transaction_id" "text",
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "idempotency_key" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_preferences" (
    "user_id" "uuid" NOT NULL,
    "payment_mode" "text" DEFAULT 'PREPAID'::"text" NOT NULL,
    "credit_limit" numeric(18,6) DEFAULT 50.000000 NOT NULL,
    "spending_limit" numeric(18,6) DEFAULT 100.000000 NOT NULL,
    "spending_alert_threshold" numeric(18,6) DEFAULT 80.000000 NOT NULL,
    "auto_topup_enabled" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_preferences" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_pricing" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version_name" "text" NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "storage_rate_per_gb_month" numeric(18,6) DEFAULT 0.015000 NOT NULL,
    "bandwidth_rate_per_gb" numeric(18,6) DEFAULT 0.020000 NOT NULL,
    "read_op_rate_per_10k" numeric(18,6) DEFAULT 0.003600 NOT NULL,
    "write_op_rate_per_10k" numeric(18,6) DEFAULT 0.045000 NOT NULL,
    "backup_rate_per_gb_month" numeric(18,6) DEFAULT 0.020000 NOT NULL,
    "maintenance_allocation_pct" numeric(6,4) DEFAULT 0.1200 NOT NULL,
    "founder_margin_pct" numeric(6,4) DEFAULT 0.0500 NOT NULL,
    "effective_from" timestamp with time zone DEFAULT "now"() NOT NULL,
    "effective_until" timestamp with time zone,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_pricing" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."billing_usage" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "resource_type" "text" NOT NULL,
    "quantity" numeric(18,6) NOT NULL,
    "unit" "text" NOT NULL,
    "period_start" timestamp with time zone DEFAULT "now"() NOT NULL,
    "period_end" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."billing_usage" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."blocked_users" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "blocker_id" "uuid" NOT NULL,
    "blocked_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."blocked_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_achievements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "book_id" "uuid",
    "achievement_type" "text" NOT NULL,
    "milestone_value" bigint NOT NULL,
    "unlocked_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_deleted" boolean DEFAULT false
);


ALTER TABLE "public"."book_achievements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_bookmarks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "book_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "position" "text" NOT NULL,
    "label" "text",
    "note" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_deleted" boolean DEFAULT false
);


ALTER TABLE "public"."book_bookmarks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_collection_ref" (
    "book_id" "uuid" NOT NULL,
    "collection_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "is_deleted" boolean DEFAULT false,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."book_collection_ref" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_collections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_deleted" boolean DEFAULT false
);


ALTER TABLE "public"."book_collections" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_progress" (
    "book_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "percentage" double precision DEFAULT 0,
    "pdf_page" integer,
    "epub_cfi" "text",
    "reader_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "last_opened_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "read_pages" "text"
);


ALTER TABLE "public"."book_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_quotes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "book_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "text" "text" NOT NULL,
    "location" "text" NOT NULL,
    "note" "text",
    "color" integer,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_deleted" boolean DEFAULT false,
    "type" "text" DEFAULT 'QUOTE'::"text"
);


ALTER TABLE "public"."book_quotes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."books" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "vault_file_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "author" "text",
    "format" "text" NOT NULL,
    "favorite" boolean DEFAULT false,
    "status" "text" DEFAULT 'NOT_STARTED'::"text" NOT NULL,
    "added_at" timestamp with time zone DEFAULT "now"(),
    "last_opened_at" timestamp with time zone DEFAULT "now"(),
    "authors" "text",
    "publisher" "text",
    "description" "text",
    "language" "text",
    "isbn" "text",
    "publish_date" "text",
    "subjects" "text",
    "format_version" "text",
    "page_count" integer,
    "last_read_at" timestamp with time zone,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "total_reading_time_ms" bigint DEFAULT 0,
    "is_deleted" boolean DEFAULT false,
    "goal_end_date" timestamp with time zone,
    "content_hash" "text",
    CONSTRAINT "books_format_check" CHECK (("format" = ANY (ARRAY['PDF'::"text", 'EPUB'::"text"]))),
    CONSTRAINT "books_status_check" CHECK (("status" = ANY (ARRAY['NOT_STARTED'::"text", 'READING'::"text", 'FINISHED'::"text"])))
);


ALTER TABLE "public"."books" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."broadcasts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "title" "jsonb" DEFAULT '{}'::"jsonb",
    "content" "jsonb" DEFAULT '{}'::"jsonb",
    "type" "text" DEFAULT 'TEXT'::"text",
    "media_url" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "is_official" boolean DEFAULT true,
    "published_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."broadcasts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."browser_bookmarks" (
    "userId" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "title" "text" NOT NULL,
    "folder" "text" DEFAULT 'Default'::"text",
    "parent_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "last_modified" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "is_folder" boolean DEFAULT false,
    "position" integer DEFAULT 0,
    "is_deleted" boolean DEFAULT false
);


ALTER TABLE "public"."browser_bookmarks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."browser_history" (
    "userId" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "title" "text" NOT NULL,
    "visitTime" bigint NOT NULL,
    "favicon_url" "text"
);


ALTER TABLE "public"."browser_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bug_reports" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "description" "text" NOT NULL,
    "system_info" "jsonb",
    "log_url" "text",
    "status" "text" DEFAULT 'open'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."bug_reports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendar_categories" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "color" "text" NOT NULL,
    "icon" "text",
    "owner_id" "uuid" NOT NULL
);


ALTER TABLE "public"."calendar_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendar_invitations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "from_user_id" "uuid" NOT NULL,
    "to_user_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."calendar_invitations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendar_items" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "color" "text",
    "icon" "text",
    "location" "text",
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "is_all_day" boolean DEFAULT false,
    "timezone" "text",
    "recurrence_rule" "text",
    "priority" "text" DEFAULT 'MEDIUM'::"text",
    "status" "text" DEFAULT 'PENDING'::"text",
    "is_private" boolean DEFAULT false,
    "owner_id" "uuid" NOT NULL,
    "category_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "meeting_type" "text",
    "meeting_link" "text",
    "progress" integer DEFAULT 0,
    "pomodoro_count" integer DEFAULT 0,
    "deadline" timestamp with time zone,
    "parent_item_id" "uuid",
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer DEFAULT 0
);


ALTER TABLE "public"."calendar_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."call_logs" (
    "id" "text" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "peer_id" "uuid",
    "peer_number" "text" NOT NULL,
    "peer_name" "text",
    "type" "text" NOT NULL,
    "is_keeftalk" boolean DEFAULT false,
    "call_type" "text",
    "duration" integer DEFAULT 0,
    "timestamp" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer,
    "is_deleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "call_logs_call_type_check" CHECK (("call_type" = ANY (ARRAY['VOICE'::"text", 'VIDEO'::"text", 'GSM'::"text"]))),
    CONSTRAINT "call_logs_type_check" CHECK (("type" = ANY (ARRAY['INCOMING'::"text", 'OUTGOING'::"text", 'MISSED'::"text", 'REJECTED'::"text"])))
);


ALTER TABLE "public"."call_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."call_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chat_id" "uuid" NOT NULL,
    "caller_id" "uuid" NOT NULL,
    "receiver_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "state" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "ended_at" timestamp with time zone,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "call_sessions_state_check" CHECK (("state" = ANY (ARRAY['idle'::"text", 'calling'::"text", 'ringing'::"text", 'connected'::"text", 'ended'::"text", 'failed'::"text"]))),
    CONSTRAINT "call_sessions_type_check" CHECK (("type" = ANY (ARRAY['VOICE'::"text", 'VIDEO'::"text"])))
);

ALTER TABLE ONLY "public"."call_sessions" REPLICA IDENTITY FULL;


ALTER TABLE "public"."call_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."call_signaling" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "call_id" "uuid" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "call_signaling_type_check" CHECK (("type" = ANY (ARRAY['offer'::"text", 'answer'::"text", 'ice-candidate'::"text", 'hangup'::"text"])))
);

ALTER TABLE ONLY "public"."call_signaling" REPLICA IDENTITY FULL;


ALTER TABLE "public"."call_signaling" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."caller_contributions" (
    "contributor_user_id" "uuid" NOT NULL,
    "phone_hash" "text" NOT NULL,
    "field_type" "text" NOT NULL,
    "candidate_value" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_contributions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."caller_id_config" (
    "key" "text" NOT NULL,
    "value" "text" NOT NULL
);


ALTER TABLE "public"."caller_id_config" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."caller_id_quotas" (
    "user_id" "uuid" NOT NULL,
    "daily_lookups" integer DEFAULT 0 NOT NULL,
    "last_lookup_date" "date" DEFAULT CURRENT_DATE,
    "is_suspended" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."caller_id_quotas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."caller_identities" (
    "phone_hash" "text" NOT NULL,
    "first_name" "text",
    "family_name" "text",
    "first_name_confidence" real DEFAULT 0.0 NOT NULL,
    "family_name_confidence" real DEFAULT 0.0 NOT NULL,
    "is_verified_profile" boolean DEFAULT false NOT NULL,
    "verified_first_name" "text",
    "verified_family_name" "text",
    "business_name" "text",
    "business_confidence" real DEFAULT 0.0 NOT NULL,
    "spam_score" real DEFAULT 0.0 NOT NULL,
    "last_updated" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_identities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."caller_nicknames" (
    "phone_hash" "text" NOT NULL,
    "nickname" "text" NOT NULL,
    "confidence" real DEFAULT 0.0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_nicknames" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."caller_spam_reporters" (
    "user_id" "uuid" NOT NULL,
    "phone_hash" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."caller_spam_reporters" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_containers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "name" "text" NOT NULL,
    "icon" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."chat_containers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_members" (
    "chat_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "joined_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "is_pinned" boolean DEFAULT false,
    "is_muted" boolean DEFAULT false,
    "is_archived" boolean DEFAULT false,
    "role" "text" DEFAULT 'member'::"text",
    "notification_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "theme_id" "text",
    "last_read_message_id" "uuid",
    "last_delivered_message_id" "uuid",
    "last_read_at" timestamp with time zone,
    "last_delivered_at" timestamp with time zone,
    "is_favorite" boolean DEFAULT false,
    "nickname" "text",
    "auto_save_photos" boolean DEFAULT false,
    "read_receipts_enabled" boolean DEFAULT true,
    "typing_indicator_enabled" boolean DEFAULT true,
    "quick_reaction" "text"
);

ALTER TABLE ONLY "public"."chat_members" REPLICA IDENTITY FULL;


ALTER TABLE "public"."chat_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text",
    "type" "text" DEFAULT 'ONE_TO_ONE'::"text" NOT NULL,
    "created_at" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "last_message_text" "text",
    "last_message_time_ms" bigint,
    "avatar_url" "text",
    "auto_delete_timer" bigint,
    "container_id" "uuid",
    "last_message_id" "uuid",
    "last_message_time" timestamp with time zone,
    "last_activity_at" timestamp with time zone DEFAULT "now"(),
    "auto_translate_enabled" boolean DEFAULT false,
    "last_message_status" "text",
    "last_message_sender_id" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "quick_reaction" "text" DEFAULT 'VOICE'::"text"
);

ALTER TABLE ONLY "public"."chats" REPLICA IDENTITY FULL;


ALTER TABLE "public"."chats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "full_name" "text",
    "email" "text",
    "phone" "text",
    "avatar_url" "text",
    "last_seen" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "fcm_token" "text",
    "cover_url" "text",
    "bio" "text",
    "country" "text",
    "avatar_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "cover_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "phone_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "email_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "bio_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "last_seen_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "online_status_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "is_verified" boolean DEFAULT false,
    "join_date" bigint DEFAULT (EXTRACT("epoch" FROM "now"()) * (1000)::numeric),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "country_code" "text",
    "nudges_received" integer DEFAULT 0,
    "views_count" bigint DEFAULT 0,
    "plan_type" "text" DEFAULT 'FREE'::"text",
    "storage_limit" bigint DEFAULT '5368709120'::bigint,
    "storage_used" bigint DEFAULT 0,
    "is_family_owner" boolean DEFAULT false,
    "family_id" "uuid",
    "caller_id_enabled" boolean DEFAULT true NOT NULL,
    "caller_id_contribute" boolean DEFAULT true NOT NULL,
    "phone_hmac" "text",
    "preferred_language" "text" DEFAULT 'en'::"text",
    "is_official" boolean DEFAULT false,
    "use_anonymous_market_identity" boolean DEFAULT false,
    "market_anon_name" "text" DEFAULT ''::"text",
    "market_anon_avatar_url" "text",
    "last_name_change_at" timestamp with time zone,
    "phone_verified" boolean DEFAULT false,
    "total_xp" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "bio_length_check" CHECK (("char_length"("bio") <= 250))
);

ALTER TABLE ONLY "public"."profiles" REPLICA IDENTITY FULL;


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."chat_list_metadata" WITH ("security_invoker"='on') AS
 SELECT "c"."id" AS "chat_id",
    "c"."type",
    "c"."name" AS "group_name",
    "c"."avatar_url" AS "group_avatar",
    "cm"."user_id" AS "member_id",
    "p"."id" AS "partner_id",
    COALESCE("p"."full_name", "p"."username", "p"."phone", 'User'::"text") AS "partner_display_name",
    "p"."avatar_url" AS "partner_avatar",
    "p"."fcm_token" AS "partner_fcm_token"
   FROM ((("public"."chats" "c"
     JOIN "public"."chat_members" "cm" ON (("c"."id" = "cm"."chat_id")))
     LEFT JOIN "public"."chat_members" "cm2" ON ((("c"."id" = "cm2"."chat_id") AND ("cm2"."user_id" <> "cm"."user_id"))))
     LEFT JOIN "public"."profiles" "p" ON (("cm2"."user_id" = "p"."id")))
  WHERE (("c"."type" = 'ONE_TO_ONE'::"text") OR ("cm2"."user_id" IS NULL));


ALTER VIEW "public"."chat_list_metadata" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reporter_id" "uuid",
    "chat_id" "uuid",
    "reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."chat_reports" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."community_growth_daily" AS
 SELECT ("date_trunc"('day'::"text", "to_timestamp"((("join_date" / 1000))::double precision)))::"date" AS "day",
    "count"(*) AS "new_users"
   FROM "public"."profiles"
  WHERE ("join_date" > ((EXTRACT("epoch" FROM ("now"() - '30 days'::interval)) * (1000)::numeric))::bigint)
  GROUP BY (("date_trunc"('day'::"text", "to_timestamp"((("join_date" / 1000))::double precision)))::"date")
  ORDER BY (("date_trunc"('day'::"text", "to_timestamp"((("join_date" / 1000))::double precision)))::"date") DESC;


ALTER VIEW "public"."community_growth_daily" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."contacts" (
    "id" "text" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "username" "text",
    "phone" "text",
    "email" "text",
    "avatar_url" "text",
    "secondary_phone" "text",
    "secondary_phone_label" "text",
    "tertiary_phone" "text",
    "tertiary_phone_label" "text",
    "birthday" bigint,
    "calling_card" "text",
    "is_keeftalk_user" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer
);

ALTER TABLE ONLY "public"."contacts" REPLICA IDENTITY FULL;


ALTER TABLE "public"."contacts" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."connections" WITH ("security_invoker"='true') AS
 SELECT "c"."owner_id" AS "user_a",
    "p"."id" AS "user_b"
   FROM ("public"."contacts" "c"
     JOIN "public"."profiles" "p" ON (("c"."phone" = "p"."phone")));


ALTER VIEW "public"."connections" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."conversation_keys" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "conversation_id" "text" NOT NULL,
    "encrypted_key" "text" NOT NULL,
    "nonce" "text" NOT NULL,
    "version" integer DEFAULT 1,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "epoch" integer DEFAULT 1
);


ALTER TABLE "public"."conversation_keys" OWNER TO "postgres";


COMMENT ON TABLE "public"."conversation_keys" IS 'Stores conversation encryption keys (PCKs) wrapped with the user AEK for multi-device sync.';



CREATE TABLE IF NOT EXISTS "public"."data_exports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "file_path" "text" NOT NULL,
    "encryption_key_hash" "text",
    "status" "text" DEFAULT 'COMPLETED'::"text",
    "expires_at" timestamp with time zone DEFAULT ("now"() + '14 days'::interval),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."data_exports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."families" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "name" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."families" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."family_groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "text",
    "storage_limit_bytes" bigint DEFAULT '2199023255552'::bigint NOT NULL,
    "max_total_users" integer DEFAULT 6 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."family_groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."family_permissions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "family_member_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "level" "text" DEFAULT 'VIEW'::"text" NOT NULL
);


ALTER TABLE "public"."family_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."feature_sync_plans" (
    "id" "text" NOT NULL,
    "feature_id" "text",
    "display_name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "price" numeric(12,2) DEFAULT 0.99 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "billing_period" "text" DEFAULT 'MONTHLY'::"text" NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."feature_sync_plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."files" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "storage_path" "text" NOT NULL,
    "file_hash" "text",
    "file_name" "text",
    "mime_type" "text",
    "file_size" bigint,
    "file_type" "text",
    "source_type" "text" NOT NULL,
    "width" integer,
    "height" integer,
    "duration" integer,
    "thumbnail_path" "text",
    "encryption_metadata" "jsonb",
    "reference_count" integer DEFAULT 0,
    "status" "text" DEFAULT 'ACTIVE'::"text",
    "security_metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    "local_path" "text",
    "thumbnail_remote_path" "text",
    "thumbnail_size" bigint,
    "thumbnail_width" integer,
    "thumbnail_height" integer,
    "thumbnail_hmac" "text",
    "fps" integer,
    "video_codec" "text",
    "audio_codec" "text",
    "bitrate" bigint,
    "sample_rate" integer,
    "channels" integer,
    "pages" integer,
    "extended_metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "physical_size" "text",
    "archived_at" timestamp with time zone,
    "detention_at" timestamp with time zone,
    "scheduled_purge_at" timestamp with time zone,
    "original_bucket" "text",
    "original_path" "text",
    "original_category" "text"
);

ALTER TABLE ONLY "public"."files" REPLICA IDENTITY FULL;


ALTER TABLE "public"."files" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."habit_checkins" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "habit_id" "uuid" NOT NULL,
    "epoch_day" bigint NOT NULL,
    "completed" boolean DEFAULT true NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."habit_checkins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."habit_grace_uses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "habit_id" "uuid" NOT NULL,
    "forgiven_date" "date" NOT NULL,
    "used_date" "date" NOT NULL,
    "used_month_key" "text" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."habit_grace_uses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."habit_logs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "habit_id" "uuid" NOT NULL,
    "date" "date" NOT NULL,
    "status" "text" NOT NULL,
    "note" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."habit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."habit_milestones" (
    "user_id" "uuid" NOT NULL,
    "key" "text" NOT NULL,
    "unlocked_at_epoch_day" bigint NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."habit_milestones" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."habit_schedules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "habit_id" "uuid" NOT NULL,
    "effective_from" "date" NOT NULL,
    "days_mask" integer DEFAULT 127 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."habit_schedules" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."habits" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "color" "text",
    "icon" "text",
    "recurrence_rule" "text" NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_active" boolean DEFAULT true,
    "category" "text" DEFAULT 'drink'::"text" NOT NULL,
    "base_days" integer DEFAULT 18 NOT NULL,
    "created_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "reminder_time_minutes" integer,
    "slot" "text" DEFAULT 'Morning'::"text" NOT NULL,
    "habit_type" "text" DEFAULT 'AUTO'::"text" NOT NULL,
    "amount" integer,
    "unit" "text",
    "color_hex" "text" DEFAULT '#00CCCC'::"text" NOT NULL,
    "is_reading_habit" boolean DEFAULT false NOT NULL,
    "auto_count_reading" boolean DEFAULT true NOT NULL,
    "linked_book_ids" "text" DEFAULT ''::"text" NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."habits" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."invitation_permissions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "invitation_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "level" "text" DEFAULT 'VIEW'::"text" NOT NULL
);


ALTER TABLE "public"."invitation_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "content" "text" NOT NULL,
    "version" integer DEFAULT 1 NOT NULL,
    "is_active" boolean DEFAULT false NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "legal_documents_type_check" CHECK (("type" = ANY (ARRAY['terms'::"text", 'privacy'::"text"])))
);


ALTER TABLE "public"."legal_documents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."link_previews" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "url" "text" NOT NULL,
    "normalized_url" "text" NOT NULL,
    "canonical_url" "text",
    "domain" "text",
    "title" "text",
    "description" "text",
    "image_url" "text",
    "favicon_url" "text",
    "site_name" "text",
    "metadata" "jsonb",
    "status" "text" DEFAULT 'SUCCESS'::"text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "expires_at" timestamp with time zone
);


ALTER TABLE "public"."link_previews" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."login_attempts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "ip_address" "text",
    "success" boolean DEFAULT false,
    "failure_reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."login_attempts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_categories" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "icon_name" "text" DEFAULT 'category'::"text" NOT NULL,
    "subcategories" "jsonb" DEFAULT '[]'::"jsonb"
);


ALTER TABLE "public"."market_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "text",
    "buyer_id" "uuid",
    "seller_id" "uuid",
    "as_identity" "text" DEFAULT 'alias'::"text" NOT NULL,
    "start_ts" bigint DEFAULT 0 NOT NULL,
    "status" "text",
    "messages" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "review_state" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_chats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_favorites" (
    "user_id" "uuid" NOT NULL,
    "listing_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_favorites" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_listing_extensions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "text",
    "buyer_id" "text",
    "extended_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_listing_extensions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_listing_media" (
    "id" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "listing_id" "text" NOT NULL,
    "url" "text" NOT NULL,
    "thumbnail_url" "text",
    "is_video" boolean DEFAULT false NOT NULL,
    "width" integer DEFAULT 1080 NOT NULL,
    "height" integer DEFAULT 1080 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_listing_media" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_listings" (
    "id" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "seller_id" "uuid" NOT NULL,
    "seller_name" "text" NOT NULL,
    "seller_avatar_url" "text",
    "seller_joined_year" "text" DEFAULT '2024'::"text",
    "seller_rating" numeric(3,2) DEFAULT 5.0,
    "seller_total_sales" integer DEFAULT 0,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "category_id" "text" NOT NULL,
    "category_name" "text" NOT NULL,
    "subcategory" "text",
    "price" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'TND'::"text" NOT NULL,
    "is_negotiable" boolean DEFAULT true NOT NULL,
    "condition" "text" DEFAULT 'USED'::"text" NOT NULL,
    "brand" "text",
    "model" "text",
    "location_area" "text" NOT NULL,
    "latitude" double precision,
    "longitude" double precision,
    "primary_image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '30 days'::interval) NOT NULL,
    "status" "text" DEFAULT 'ACTIVE'::"text" NOT NULL,
    "views_count" integer DEFAULT 0 NOT NULL,
    "saves_count" integer DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid",
    "cat" "text" DEFAULT 'other'::"text" NOT NULL,
    "sub" "text" DEFAULT 'Other'::"text" NOT NULL,
    "cd" "text" DEFAULT 'good'::"text" NOT NULL,
    "seller_alias" "text" DEFAULT ''::"text" NOT NULL,
    "as_identity" "text" DEFAULT 'alias'::"text" NOT NULL,
    "shape" "text" DEFAULT 'v'::"text" NOT NULL,
    "ts" bigint DEFAULT 0 NOT NULL,
    "exp" bigint DEFAULT 0 NOT NULL,
    "ext" integer DEFAULT 0 NOT NULL,
    "media" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "is_sold" boolean DEFAULT false NOT NULL,
    "pos_lat" double precision,
    "pos_lng" double precision
);


ALTER TABLE "public"."market_listings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_offers" (
    "id" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "listing_id" "text" NOT NULL,
    "buyer_id" "uuid" NOT NULL,
    "buyer_name" "text" NOT NULL,
    "offer_amount" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'TND'::"text" NOT NULL,
    "message" "text",
    "counter_amount" numeric(12,2),
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_offers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reporter_id" "uuid" NOT NULL,
    "kind" "text" DEFAULT 'post'::"text" NOT NULL,
    "target_id" "text" DEFAULT ''::"text" NOT NULL,
    "reason" "text" DEFAULT ''::"text" NOT NULL,
    "text" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_reports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_saved" (
    "user_id" "uuid" NOT NULL,
    "listing_id" "text" NOT NULL,
    "saved_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_saved" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."market_sellers" (
    "id" "uuid" NOT NULL,
    "alias" "text" DEFAULT ''::"text" NOT NULL,
    "real_name" "text" DEFAULT ''::"text" NOT NULL,
    "since_year" integer DEFAULT EXTRACT("year" FROM CURRENT_DATE) NOT NULL,
    "verified" integer DEFAULT 0 NOT NULL,
    "reviews" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."market_sellers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."message_attachment" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "message_id" "uuid" NOT NULL,
    "file_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."message_attachment" REPLICA IDENTITY FULL;


ALTER TABLE "public"."message_attachment" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."message_link_previews" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "message_id" "uuid" NOT NULL,
    "link_preview_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."message_link_previews" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."message_reactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "message_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "emoji" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."message_reactions" REPLICA IDENTITY FULL;


ALTER TABLE "public"."message_reactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."message_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "recipient_id" "uuid" NOT NULL,
    "conversation_id" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "policy_version" integer DEFAULT 1,
    "messages_sent" integer DEFAULT 1,
    "recipient_replied" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone DEFAULT ("now"() + '7 days'::interval)
);


ALTER TABLE "public"."message_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."message_visibility" (
    "message_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "is_hidden" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_blurred" boolean DEFAULT false,
    "is_locked" boolean DEFAULT false,
    "updated_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."message_visibility" REPLICA IDENTITY FULL;


ALTER TABLE "public"."message_visibility" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chat_id" "uuid",
    "sender_id" "uuid" NOT NULL,
    "content" "text",
    "type" "text" DEFAULT 'TEXT'::"text" NOT NULL,
    "timestamp" bigint DEFAULT ((EXTRACT("epoch" FROM "now"()) * (1000)::numeric))::bigint NOT NULL,
    "status" "text" DEFAULT 'SENT'::"text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "source_language" "text",
    "reply_to_id" "uuid",
    "conversation_id" "text",
    "reply_to_message_id" "uuid",
    "reply_to_text" "text",
    "reply_to_sender" "text",
    "media_locked" boolean DEFAULT false,
    "media_lock_updated_at" bigint,
    "media_lock_updated_by" "uuid",
    "ciphertext" "text",
    "crypto_version" integer DEFAULT 0,
    "envelope_type" integer DEFAULT 0,
    "height" bigint,
    "width" bigint,
    "nonce" "text",
    "is_ai_response" boolean DEFAULT false,
    "edited_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "media_blurred" boolean DEFAULT false,
    "is_deleted_me" boolean DEFAULT false,
    "message_attachment" "text",
    "message_link_previews" "text",
    "message_reactions" "text",
    "message_visibility" "text",
    CONSTRAINT "messages_status_check" CHECK (("status" = ANY (ARRAY['SENT'::"text", 'DELIVERED'::"text", 'FCM_RECEIVED'::"text", 'SEEN'::"text", 'FAILED'::"text"]))),
    CONSTRAINT "messages_type_check" CHECK (("type" = ANY (ARRAY['TEXT'::"text", 'IMAGE'::"text", 'VIDEO'::"text", 'VOICE'::"text", 'FILE'::"text", 'PDF'::"text", 'LOCATION'::"text", 'CONTACT'::"text", 'POLL'::"text", 'CALL_LOG'::"text", 'SHARED_NOTE'::"text", 'SHARED_EMAIL'::"text", 'SHARED_VAULT_FILE'::"text", 'SHARED_AGENDA'::"text", 'REACTION'::"text"])))
);

ALTER TABLE ONLY "public"."messages" REPLICA IDENTITY FULL;


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."note_attachment" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "note_id" "uuid" NOT NULL,
    "file_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."note_attachment" REPLICA IDENTITY FULL;


ALTER TABLE "public"."note_attachment" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."note_shares" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "note_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "access" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "note_shares_access_check" CHECK (("access" = ANY (ARRAY['read'::"text", 'write'::"text"])))
);

ALTER TABLE ONLY "public"."note_shares" REPLICA IDENTITY FULL;


ALTER TABLE "public"."note_shares" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "title" "text" DEFAULT 'Untitled'::"text",
    "content" "text" DEFAULT ''::"text",
    "color" "text" DEFAULT '#6C63FF'::"text",
    "pinned" boolean DEFAULT false,
    "archived" boolean DEFAULT false,
    "container" "text" DEFAULT 'All'::"text",
    "can_others_add" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer DEFAULT 0
);

ALTER TABLE ONLY "public"."notes" REPLICA IDENTITY FULL;


ALTER TABLE "public"."notes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notes_sync_queue" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "note_id" "uuid" NOT NULL,
    "operation" "text" NOT NULL,
    "payload" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "retry_count" integer DEFAULT 0,
    "status" "text" DEFAULT 'PENDING'::"text"
);


ALTER TABLE "public"."notes_sync_queue" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "data" "jsonb",
    "is_read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "priority" "text" DEFAULT 'NORMAL'::"text",
    "source_id" "text",
    "nudge_count" integer DEFAULT 1
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."official_broadcast_actions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "broadcast_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "action_type" "text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."official_broadcast_actions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pinned_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chat_id" "uuid" NOT NULL,
    "message_id" "uuid" NOT NULL,
    "pinned_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pinned_messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."premium_products_config" (
    "product_id" "text" NOT NULL,
    "product_type" "text" DEFAULT 'UNIVERSAL_PREMIUM'::"text" NOT NULL,
    "display_name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "price" numeric(12,2) DEFAULT 9.99 NOT NULL,
    "currency" "text" DEFAULT 'USD'::"text" NOT NULL,
    "billing_period" "text" DEFAULT 'MONTHLY'::"text" NOT NULL,
    "storage_limit_bytes" bigint DEFAULT '536870912000'::bigint NOT NULL,
    "max_members" integer DEFAULT 1 NOT NULL,
    "capabilities" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."premium_products_config" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profile_background_media" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "media_type" "text" NOT NULL,
    "storage_path" "text" NOT NULL,
    "width" integer NOT NULL,
    "height" integer NOT NULL,
    "duration_seconds" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "profile_background_media_media_type_check" CHECK (("media_type" = ANY (ARRAY['IMAGE'::"text", 'VIDEO'::"text"])))
);


ALTER TABLE "public"."profile_background_media" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profile_views" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "viewer_id" "uuid" NOT NULL,
    "viewed_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "viewer_privacy_level" "text" DEFAULT 'EVERYONE'::"text",
    "viewed_privacy_level" "text" DEFAULT 'EVERYONE'::"text"
);

ALTER TABLE ONLY "public"."profile_views" REPLICA IDENTITY FULL;


ALTER TABLE "public"."profile_views" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reading_sessions" (
    "id" "uuid" NOT NULL,
    "book_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "duration_ms" bigint DEFAULT 0 NOT NULL,
    "pages_read" integer DEFAULT 0 NOT NULL,
    "start_location" "text",
    "end_location" "text",
    "is_manual" boolean DEFAULT false NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."reading_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reading_stats" (
    "date" "date" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "time_spent_millis" bigint DEFAULT 0,
    "pages_read" integer DEFAULT 0,
    "books_finished" integer DEFAULT 0,
    "sessions_count" integer DEFAULT 0,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."reading_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."redeem_codes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "type" "text" DEFAULT 'FEATURE'::"text" NOT NULL,
    "plan_type" "text",
    "storage_limit" bigint,
    "feature_keys" "text"[],
    "max_uses" integer DEFAULT 1,
    "used_count" integer DEFAULT 0,
    "expires_at" timestamp with time zone,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."redeem_codes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."redeem_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "code_id" "uuid",
    "code" "text" NOT NULL,
    "redeemed_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."redeem_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."relationship_intelligence" (
    "user_a" "uuid" NOT NULL,
    "user_b" "uuid" NOT NULL,
    "strength_score" double precision DEFAULT 0.0,
    "last_interaction_at" timestamp with time zone,
    "interaction_count_30d" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."relationship_intelligence" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."relationships" (
    "user_id" "uuid" NOT NULL,
    "target_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'ACTIVE'::"text",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."relationships" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reporter_id" "uuid",
    "reported_user_id" "uuid",
    "chat_id" "uuid",
    "reason" "text" NOT NULL,
    "details" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."reports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."secret_backup_codes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "encrypted_code" "text" NOT NULL,
    "is_used" boolean DEFAULT false NOT NULL,
    "used_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_backup_codes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."secret_credentials" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "service_name" "text" NOT NULL,
    "website" "text" DEFAULT ''::"text",
    "username" "text" DEFAULT ''::"text",
    "encrypted_password" "text" NOT NULL,
    "category" "text" DEFAULT 'Personal'::"text" NOT NULL,
    "password_strength" integer DEFAULT 0 NOT NULL,
    "has_two_factor" boolean DEFAULT false NOT NULL,
    "notes" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."secret_credentials" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."secret_password_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "credential_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "encrypted_password" "text" NOT NULL,
    "set_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "replaced_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_password_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."secret_settings" (
    "user_id" "uuid" NOT NULL,
    "auto_lock_minutes" integer DEFAULT 5 NOT NULL,
    "block_screenshots" boolean DEFAULT true NOT NULL,
    "clear_clipboard_seconds" integer DEFAULT 30 NOT NULL,
    "wipe_after_failed_tries" boolean DEFAULT true NOT NULL,
    "encrypted_backup_enabled" boolean DEFAULT false NOT NULL,
    "biometric_required" boolean DEFAULT true NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."secret_totp_accounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "service_name" "text" NOT NULL,
    "username" "text" DEFAULT ''::"text",
    "encrypted_secret_key" "text" NOT NULL,
    "issuer" "text" DEFAULT ''::"text",
    "algorithm" "text" DEFAULT 'SHA1'::"text" NOT NULL,
    "digits" integer DEFAULT 6 NOT NULL,
    "period" integer DEFAULT 30 NOT NULL,
    "color_hex" "text" DEFAULT '#7D5CFF'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_totp_accounts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."secret_vault_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "item_type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "encrypted_content" "text" NOT NULL,
    "subtitle" "text" DEFAULT ''::"text",
    "is_locked" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."secret_vault_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."security_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "event_type" "text" NOT NULL,
    "description" "text",
    "device_id" "text",
    "ip_address" "text",
    "country" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "city" "text",
    "status" "text" DEFAULT 'SUCCESS'::"text"
);


ALTER TABLE "public"."security_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sms_messages" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "thread_id" "text" NOT NULL,
    "address" "text",
    "body" "text",
    "timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "read" integer DEFAULT 0 NOT NULL,
    "type" integer DEFAULT 1 NOT NULL,
    "status" integer DEFAULT 0 NOT NULL,
    "is_mms" boolean DEFAULT false NOT NULL,
    "attachments_json" "text",
    "delivery_status" integer DEFAULT '-1'::integer NOT NULL,
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sms_messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sms_threads" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "address" "text",
    "snippet" "text",
    "timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "unread_count" integer DEFAULT 0 NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_muted" boolean DEFAULT false NOT NULL,
    "is_pinned" boolean DEFAULT false NOT NULL,
    "ciphertext" "text",
    "iv" "text",
    "crypto_version" integer,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sms_threads" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."storage_lifecycle_queue" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "file_id" "uuid" NOT NULL,
    "user_id" "text" NOT NULL,
    "action" "text" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "attempts" integer DEFAULT 0,
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."storage_lifecycle_queue" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_device_install_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "extension_id" "text" NOT NULL,
    "version" "text" NOT NULL,
    "device_id" "text" DEFAULT 'default_device'::"text",
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '00:10:00'::interval) NOT NULL
);


ALTER TABLE "public"."store_device_install_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_extensions" (
    "id" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" DEFAULT 'TOOL'::"text" NOT NULL,
    "publisher_id" "text" NOT NULL,
    "short_description" "text" DEFAULT ''::"text",
    "long_description" "text" DEFAULT ''::"text",
    "category" "text" DEFAULT 'tools'::"text" NOT NULL,
    "age_rating" "text" DEFAULT '4+'::"text" NOT NULL,
    "languages" "text"[] DEFAULT '{English}'::"text"[] NOT NULL,
    "compatible_modules" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "min_app_version" "text" DEFAULT '3.0.0'::"text" NOT NULL,
    "current_version" "text" DEFAULT '1.0.0'::"text" NOT NULL,
    "status" "text" DEFAULT 'DRAFT'::"text" NOT NULL,
    "is_featured" boolean DEFAULT false NOT NULL,
    "download_count" bigint DEFAULT 0 NOT NULL,
    "install_count" bigint DEFAULT 0 NOT NULL,
    "rating_avg" numeric(3,2) DEFAULT 0.00 NOT NULL,
    "rating_count" integer DEFAULT 0 NOT NULL,
    "cover_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "screenshot01" "text",
    "screenshot02" "text",
    "screenshot03" "text",
    "screenshot04" "text",
    "screenshot05" "text",
    "screenshot06" "text",
    "screenshot07" "text"
);


ALTER TABLE "public"."store_extensions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_installations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "device_id" "text" DEFAULT 'default_device'::"text" NOT NULL,
    "installed_version" "text" NOT NULL,
    "country_code" "text" DEFAULT 'GLOBAL'::"text" NOT NULL,
    "status" "text" DEFAULT 'INSTALLED'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_installations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_media_assets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "release_version" "text" NOT NULL,
    "asset_type" "text" NOT NULL,
    "object_key" "text" NOT NULL,
    "display_order" integer DEFAULT 0 NOT NULL,
    "file_size_bytes" bigint DEFAULT 0,
    "hash_sha256" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "store_media_assets_asset_type_check" CHECK (("asset_type" = ANY (ARRAY['COVER'::"text", 'SCREENSHOT'::"text"])))
);


ALTER TABLE "public"."store_media_assets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_publishers" (
    "id" "text" NOT NULL,
    "user_id" "uuid",
    "display_name" "text" NOT NULL,
    "description" "text" DEFAULT ''::"text",
    "website" "text",
    "is_verified" boolean DEFAULT false NOT NULL,
    "is_developer_approved" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_publishers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_ratings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "rating" integer NOT NULL,
    "review_text" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "store_ratings_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


ALTER TABLE "public"."store_ratings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_releases" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "version" "text" NOT NULL,
    "package_object_key" "text" NOT NULL,
    "package_hash_sha256" "text" NOT NULL,
    "package_size_bytes" bigint DEFAULT 0 NOT NULL,
    "release_notes" "text" DEFAULT ''::"text",
    "min_app_version" "text" DEFAULT '3.0.0'::"text" NOT NULL,
    "signing_key_id" "text" DEFAULT 'official-keeftalk-key-2026'::"text" NOT NULL,
    "status" "text" DEFAULT 'PUBLISHED'::"text" NOT NULL,
    "published_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_releases" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extension_id" "text" NOT NULL,
    "publisher_id" "text" NOT NULL,
    "version" "text" NOT NULL,
    "package_object_key" "text" NOT NULL,
    "status" "text" DEFAULT 'UPLOADED'::"text" NOT NULL,
    "validation_report" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "submitted_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."store_submissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscription_key_redemptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "key_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "redeemed_at" timestamp with time zone DEFAULT "now"(),
    "entitlement_start" timestamp with time zone NOT NULL,
    "entitlement_expiration" timestamp with time zone,
    "resulting_plan" "public"."subscription_plan",
    "resulting_storage" bigint,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb"
);


ALTER TABLE "public"."subscription_key_redemptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscription_keys" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "key_hash" "text" NOT NULL,
    "key_prefix" "text" NOT NULL,
    "entitlement_type" "text" NOT NULL,
    "plan" "public"."subscription_plan" DEFAULT 'FREE'::"public"."subscription_plan" NOT NULL,
    "storage_bytes" bigint DEFAULT 0,
    "duration_seconds" bigint,
    "lifetime" boolean DEFAULT false,
    "max_redemptions" integer DEFAULT 1,
    "redemption_count" integer DEFAULT 0,
    "valid_from" timestamp with time zone DEFAULT "now"(),
    "valid_until" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "revoked_at" timestamp with time zone,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "subscription_keys_entitlement_type_check" CHECK (("entitlement_type" = ANY (ARRAY['plan'::"text", 'storage'::"text", 'combined'::"text"])))
);


ALTER TABLE "public"."subscription_keys" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscription_metadata" (
    "id" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "price" "text" NOT NULL,
    "storage_limit" bigint NOT NULL,
    "max_file_size" bigint NOT NULL,
    "description" "text",
    "features" "jsonb" DEFAULT '[]'::"jsonb",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."subscription_metadata" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscriptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "plan" "public"."subscription_plan" DEFAULT 'FREE'::"public"."subscription_plan" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "purchase_token" "text",
    "order_id" "text",
    "expiry_date" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."subscriptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."system_metrics" (
    "id" integer NOT NULL,
    "metric_name" "text" NOT NULL,
    "metric_value" "text" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."system_metrics" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."system_metrics_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."system_metrics_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."system_metrics_id_seq" OWNED BY "public"."system_metrics"."id";



CREATE TABLE IF NOT EXISTS "public"."todo_lists" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "color_hex" "text" DEFAULT '#7D5CFF'::"text" NOT NULL,
    "updated_at" bigint NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."todo_lists" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."todo_tasks" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "notes" "text" DEFAULT ''::"text" NOT NULL,
    "due_date" "text" DEFAULT ''::"text" NOT NULL,
    "priority" integer DEFAULT 1 NOT NULL,
    "list_id" "text",
    "completed" boolean DEFAULT false NOT NULL,
    "created_at" bigint NOT NULL,
    "completed_at" bigint DEFAULT 0 NOT NULL,
    "reminder" "text" DEFAULT ''::"text" NOT NULL,
    "reminder_fired" boolean DEFAULT false NOT NULL,
    "updated_at" bigint NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."todo_tasks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."two_factor_login_challenges" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "allowed_factors" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "preferred_factor" "text",
    "verification_token" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone DEFAULT ("now"() + '00:10:00'::interval) NOT NULL,
    "verified_at" timestamp with time zone,
    CONSTRAINT "two_factor_login_challenges_status_check" CHECK (("status" = ANY (ARRAY['PENDING'::"text", 'VERIFIED'::"text", 'EXPIRED'::"text"])))
);


ALTER TABLE "public"."two_factor_login_challenges" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."two_factor_otp_challenges" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "factor_type" "text" NOT NULL,
    "purpose" "text" NOT NULL,
    "otp_hash" "text" NOT NULL,
    "destination_masked" "text",
    "expires_at" timestamp with time zone NOT NULL,
    "attempt_count" integer DEFAULT 0,
    "max_attempts" integer DEFAULT 5,
    "resend_cooldown_until" timestamp with time zone,
    "consumed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "two_factor_otp_challenges_factor_type_check" CHECK (("factor_type" = ANY (ARRAY['totp'::"text", 'email'::"text", 'sms'::"text", 'backup_code'::"text"]))),
    CONSTRAINT "two_factor_otp_challenges_purpose_check" CHECK (("purpose" = ANY (ARRAY['ENROLLMENT'::"text", 'LOGIN'::"text", 'SECURITY_ACTION'::"text"])))
);


ALTER TABLE "public"."two_factor_otp_challenges" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."usage_sessions" (
    "session_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "started_at" bigint NOT NULL,
    "ended_at" bigint NOT NULL,
    "duration_ms" bigint NOT NULL,
    "source" "text" NOT NULL,
    "feature" "text" NOT NULL,
    "created_at" bigint NOT NULL
);


ALTER TABLE "public"."usage_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_2fa_backup_codes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "code_hash" "text" NOT NULL,
    "used" boolean DEFAULT false,
    "used_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_2fa_backup_codes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_2fa_factors" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "factor_type" "text" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "verified_destination" "text",
    "totp_secret" "text",
    "is_preferred" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "last_used_at" timestamp with time zone,
    CONSTRAINT "user_2fa_factors_factor_type_check" CHECK (("factor_type" = ANY (ARRAY['totp'::"text", 'email'::"text", 'sms'::"text"]))),
    CONSTRAINT "user_2fa_factors_status_check" CHECK (("status" = ANY (ARRAY['PENDING'::"text", 'ACTIVE'::"text", 'DISABLED'::"text"])))
);


ALTER TABLE "public"."user_2fa_factors" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_app_customization" (
    "user_id" "uuid" NOT NULL,
    "enabled_modules" "text"[] DEFAULT '{CHATS,CALLS,SMS,AGENDA,NOTES,EMAIL,VAULT}'::"text"[] NOT NULL,
    "bottom_nav_tabs" "text"[] DEFAULT '{CHATS,CALLS}'::"text"[] NOT NULL,
    "enabled_fab_actions" "text"[] DEFAULT '{NEW_CHAT,NEW_GROUP,QR,AI,ACCESSIBILITY}'::"text"[] NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_enabled" boolean DEFAULT true NOT NULL,
    "sync_enabled" boolean DEFAULT true NOT NULL,
    "fab_size_multiplier" double precision DEFAULT 0.8 NOT NULL,
    "secondary_fab_size_multiplier" double precision DEFAULT 0.8 NOT NULL,
    "chat_spacing_multiplier" double precision DEFAULT 0.5 NOT NULL,
    "onboarding_completed" boolean DEFAULT false
);


ALTER TABLE "public"."user_app_customization" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_book_bookmarks" (
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "page_number" integer NOT NULL,
    "chapter_title" "text" DEFAULT ''::"text" NOT NULL,
    "excerpt" "text" DEFAULT ''::"text" NOT NULL,
    "is_user" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_bookmarks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_book_highlights" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "page_number" integer NOT NULL,
    "start_offset" integer NOT NULL,
    "end_offset" integer NOT NULL,
    "selected_text" "text" DEFAULT ''::"text" NOT NULL,
    "color_hex" "text" DEFAULT '#2ECC71'::"text" NOT NULL,
    "is_quote" boolean DEFAULT false NOT NULL,
    "note_text" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_highlights" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_book_progress" (
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "page_number" integer NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "phrase_dock_index" integer,
    "free_x" real,
    "free_y" real,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_book_sessions" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "book_id" "text" NOT NULL,
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "pages_read" integer DEFAULT 0 NOT NULL,
    "duration_seconds" bigint DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_book_settings" (
    "user_id" "uuid" NOT NULL,
    "show_read_marker" boolean DEFAULT true NOT NULL,
    "button_size_px" integer DEFAULT 38 NOT NULL,
    "green_opacity_percent" integer DEFAULT 50 NOT NULL,
    "read_marker_color_hex" "text" DEFAULT '#2ECC71'::"text" NOT NULL,
    "theme" "text" DEFAULT 'original'::"text" NOT NULL,
    "page_margins_enabled" boolean DEFAULT true NOT NULL,
    "keep_screen_on" boolean DEFAULT true NOT NULL,
    "auto_next_page_on_read" boolean DEFAULT true NOT NULL,
    "volume_keys_turn_page" boolean DEFAULT false NOT NULL,
    "sync_across_devices" boolean DEFAULT true NOT NULL,
    "daily_goal_minutes" integer DEFAULT 30 NOT NULL,
    "yearly_goal_books" integer DEFAULT 24 NOT NULL,
    "pdf_dpi_option" "text" DEFAULT 'lowest'::"text" NOT NULL,
    "pdf_custom_dpi" integer DEFAULT 200 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_book_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_books" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "author" "text" DEFAULT ''::"text" NOT NULL,
    "total_pages" integer DEFAULT 1 NOT NULL,
    "format" "text" DEFAULT 'PDF'::"text" NOT NULL,
    "cover_url" "text",
    "custom_cover_json" "text",
    "percent_progress" integer DEFAULT 0 NOT NULL,
    "last_read_page" integer DEFAULT 1 NOT NULL,
    "hours_read" real DEFAULT 0 NOT NULL,
    "pages_per_day" integer DEFAULT 10 NOT NULL,
    "speed_pages_per_hour" integer DEFAULT 30 NOT NULL,
    "insight_text" "text" DEFAULT ''::"text" NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "is_favorite" boolean DEFAULT false NOT NULL,
    "marked_done" boolean DEFAULT false NOT NULL,
    "original_progress" integer DEFAULT 0 NOT NULL,
    "original_insight" "text" DEFAULT ''::"text" NOT NULL,
    "finished_at" timestamp with time zone,
    "content_hash" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_books" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_broadcast_sync" (
    "user_id" "uuid" NOT NULL,
    "last_synced_broadcast_id" "uuid",
    "last_synced_language" "text",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_broadcast_sync" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_bundles" (
    "user_id" "uuid" NOT NULL,
    "identity_key" "text" NOT NULL,
    "signed_pre_key" "text" NOT NULL,
    "registration_id" integer NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_bundles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_chat_settings" (
    "user_id" "uuid" NOT NULL,
    "theme" "text" DEFAULT 'SYSTEM'::"text",
    "wallpaper_type" "text" DEFAULT 'COLOR'::"text",
    "wallpaper_reference" "text" DEFAULT '#F0F2F5'::"text",
    "bubble_style" "text" DEFAULT 'MODERN'::"text",
    "bubble_radius" integer DEFAULT 16,
    "chat_density" "text" DEFAULT 'COMFORTABLE'::"text",
    "animations_enabled" boolean DEFAULT true,
    "emoji_size" integer DEFAULT 24,
    "font_size" integer DEFAULT 16,
    "font_scale" double precision DEFAULT 1.0,
    "bold_text" boolean DEFAULT false,
    "high_contrast" boolean DEFAULT false,
    "reduced_motion" boolean DEFAULT false,
    "link_preview_size" "text" DEFAULT 'NORMAL'::"text",
    "auto_download_mobile" "jsonb" DEFAULT '["PHOTO"]'::"jsonb",
    "auto_download_wifi" "jsonb" DEFAULT '["PHOTO", "VIDEO", "AUDIO", "DOCUMENT"]'::"jsonb",
    "auto_download_roaming" "jsonb" DEFAULT '[]'::"jsonb",
    "upload_photo_quality" "text" DEFAULT 'HIGH'::"text",
    "upload_video_quality" "text" DEFAULT 'STANDARD'::"text",
    "autoplay_gifs" boolean DEFAULT true,
    "autoplay_videos" boolean DEFAULT true,
    "autoplay_voice_notes" boolean DEFAULT true,
    "save_to_gallery" boolean DEFAULT false,
    "enter_key_behavior" "text" DEFAULT 'SEND'::"text",
    "swipe_left_action" "text" DEFAULT 'ARCHIVE'::"text",
    "swipe_right_action" "text" DEFAULT 'REPLY'::"text",
    "double_tap_action" "text" DEFAULT 'REACT'::"text",
    "default_reaction" "text" DEFAULT '??'::"text",
    "link_previews_enabled" boolean DEFAULT true,
    "auto_translate_mode" "text" DEFAULT 'DISABLED'::"text",
    "auto_translate_language" "text" DEFAULT 'en'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_chat_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_controls" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "supervisor_id" "uuid" NOT NULL,
    "communication_restriction" "jsonb" DEFAULT '{"groups": "EVERYONE", "calling": "EVERYONE", "messaging": "EVERYONE"}'::"jsonb",
    "content_restriction" "jsonb" DEFAULT '{"link_previews": true, "media_download": "ALWAYS", "sensitive_content": "ALLOW"}'::"jsonb",
    "usage_limit" "jsonb" DEFAULT '{"quiet_hours_end": "07:00", "quiet_hours_start": "22:00", "daily_limit_minutes": 0}'::"jsonb",
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."user_controls" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_devices" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "fcm_token" "text" NOT NULL,
    "device_type" "text",
    "last_seen" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_devices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_doc_bookmarks" (
    "user_id" "uuid" NOT NULL,
    "doc_id" "text" NOT NULL,
    "page_or_position" integer NOT NULL,
    "chapter_title" "text" DEFAULT ''::"text" NOT NULL,
    "excerpt" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_doc_bookmarks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_doc_highlights" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "doc_id" "text" NOT NULL,
    "page_or_position" integer NOT NULL,
    "start_offset" integer DEFAULT 0 NOT NULL,
    "end_offset" integer DEFAULT 0 NOT NULL,
    "selected_text" "text" DEFAULT ''::"text" NOT NULL,
    "color_hex" "text" DEFAULT '#2ECC71'::"text" NOT NULL,
    "note_text" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_doc_highlights" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_doc_settings" (
    "user_id" "uuid" NOT NULL,
    "theme" "text" DEFAULT 'original'::"text" NOT NULL,
    "font_size_sp" integer DEFAULT 15 NOT NULL,
    "keep_screen_on" boolean DEFAULT true NOT NULL,
    "show_line_numbers" boolean DEFAULT true NOT NULL,
    "word_wrap" boolean DEFAULT true NOT NULL,
    "sync_across_devices" boolean DEFAULT true NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_doc_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_docs" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "author_or_source" "text" DEFAULT ''::"text" NOT NULL,
    "total_pages_or_sections" integer DEFAULT 1 NOT NULL,
    "format" "text" DEFAULT 'PDF'::"text" NOT NULL,
    "file_size" bigint DEFAULT 0 NOT NULL,
    "mime_type" "text" DEFAULT ''::"text" NOT NULL,
    "cover_url" "text",
    "custom_cover_json" "text",
    "percent_progress" integer DEFAULT 0 NOT NULL,
    "last_read_page" integer DEFAULT 1 NOT NULL,
    "last_read_position_json" "text",
    "is_favorite" boolean DEFAULT false NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "content_hash" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_docs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_drawings" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "canvas_width" integer DEFAULT 1080 NOT NULL,
    "canvas_height" integer DEFAULT 1920 NOT NULL,
    "background_color" "text" DEFAULT '#FFFFFF'::"text" NOT NULL,
    "format_version" integer DEFAULT 1 NOT NULL,
    "content_json" "text",
    "thumbnail_url" "text",
    "content_hash" "text",
    "revision" bigint DEFAULT 1 NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_drawings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_entitlements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "source" "text" NOT NULL,
    "plan" "public"."subscription_plan" DEFAULT 'FREE'::"public"."subscription_plan" NOT NULL,
    "storage_bytes" bigint DEFAULT 0,
    "starts_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone,
    "lifetime" boolean DEFAULT false,
    "source_key_id" "uuid",
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_entitlements_source_check" CHECK (("source" = ANY (ARRAY['subscription'::"text", 'redeemed_key'::"text", 'promotional'::"text", 'administrative'::"text", 'lifetime'::"text", 'other'::"text"]))),
    CONSTRAINT "user_entitlements_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'expired'::"text", 'revoked'::"text"])))
);


ALTER TABLE "public"."user_entitlements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_feature_entitlements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text",
    "feature_id" "text",
    "enabled" boolean DEFAULT true NOT NULL,
    "status" "text" DEFAULT 'ACTIVE'::"text" NOT NULL,
    "purchased_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_feature_entitlements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_prekeys" (
    "user_id" "uuid" NOT NULL,
    "registration_id" integer NOT NULL,
    "identity_key" "text" NOT NULL,
    "signed_pre_key" "jsonb" NOT NULL,
    "pre_keys" "jsonb" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_prekeys" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_presence" (
    "user_id" "uuid" NOT NULL,
    "last_seen" timestamp with time zone DEFAULT "now"(),
    "is_online" boolean DEFAULT true
);


ALTER TABLE "public"."user_presence" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_privacy_settings" (
    "user_id" "uuid" NOT NULL,
    "profile_photo_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "about_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "last_seen_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "read_receipts_enabled" boolean DEFAULT true,
    "typing_indicators_enabled" boolean DEFAULT true,
    "profile_view_history_enabled" boolean DEFAULT false,
    "call_permission" "text" DEFAULT 'EVERYONE'::"text",
    "group_permission" "text" DEFAULT 'EVERYONE'::"text",
    "screenshot_protection_enabled" boolean DEFAULT false,
    "biometric_lock_enabled" boolean DEFAULT false,
    "biometric_timeout_minutes" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "connections_visibility" "text" DEFAULT 'EVERYONE'::"text",
    "call_retention_days" integer DEFAULT 30,
    "note_lock_timeout" integer DEFAULT 0,
    "vault_auto_lock_timeout" integer DEFAULT 0,
    "email_auth_required" boolean DEFAULT false,
    "screenshot_protection_vault" boolean DEFAULT false,
    CONSTRAINT "user_privacy_settings_about_visibility_check" CHECK (("about_visibility" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_call_permission_check" CHECK (("call_permission" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_group_permission_check" CHECK (("group_permission" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_last_seen_visibility_check" CHECK (("last_seen_visibility" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"]))),
    CONSTRAINT "user_privacy_settings_profile_photo_visibility_check" CHECK (("profile_photo_visibility" = ANY (ARRAY['EVERYONE'::"text", 'CONTACTS'::"text", 'NOBODY'::"text"])))
);

ALTER TABLE ONLY "public"."user_privacy_settings" REPLICA IDENTITY FULL;


ALTER TABLE "public"."user_privacy_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_reading_xp" (
    "user_id" "uuid" NOT NULL,
    "username" "text",
    "total_xp" bigint DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_reading_xp" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_recovery_seeds" (
    "user_id" "uuid" NOT NULL,
    "recovery_seed" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_recovery_seeds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_security_settings" (
    "user_id" "uuid" NOT NULL,
    "two_factor_enabled" boolean DEFAULT false,
    "pin_hash" "text",
    "recovery_email" "text",
    "recovery_email_verified" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "app_lock_enabled" boolean DEFAULT false,
    "app_lock_timeout_seconds" integer DEFAULT 0,
    "biometric_unlock_enabled" boolean DEFAULT false,
    "encrypted_account_key" "text",
    "key_salt" "text",
    "key_nonce" "text",
    "verification_tag" "text",
    "wrapped_aek" "text",
    "wrapped_aek_recovery" "text",
    "recovery_salt" "text",
    "recovery_nonce" "text",
    "preferred_2fa_method" "text"
);

ALTER TABLE ONLY "public"."user_security_settings" REPLICA IDENTITY FULL;


ALTER TABLE "public"."user_security_settings" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_security_settings"."encrypted_account_key" IS 'User root Account Encryption Key (AEK) wrapped by password-derived KEK.';



CREATE TABLE IF NOT EXISTS "public"."user_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "device_id" "text" NOT NULL,
    "device_name" "text",
    "platform" "text",
    "app_version" "text",
    "ip_address" "text",
    "country" "text",
    "last_active" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_current" boolean DEFAULT false,
    "fcm_token" "text",
    "manufacturer" "text",
    "model" "text",
    "city" "text",
    "auth_method" "text"
);

ALTER TABLE ONLY "public"."user_sessions" REPLICA IDENTITY FULL;


ALTER TABLE "public"."user_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_settings" (
    "user_id" "uuid" NOT NULL,
    "chat_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "call_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "note_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "vault_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "calendar_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "email_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "notification_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "privacy_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "parental_controls" "jsonb" DEFAULT '{}'::"jsonb",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "sms_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "book_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "feed_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "browser_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "habit_settings" "text"
);


ALTER TABLE "public"."user_settings" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_settings"."feed_settings" IS 'User personalized feed preferences (including maxArticlesToCache, salat, weather, markets)';



COMMENT ON COLUMN "public"."user_settings"."browser_settings" IS 'User browser privacy and search settings';



CREATE TABLE IF NOT EXISTS "public"."user_storage_regions" (
    "user_id" "uuid" NOT NULL,
    "country_code" character varying(2) NOT NULL,
    "storage_region" character varying(10) NOT NULL,
    "private_bucket" "text" NOT NULL,
    "public_bucket" "text" NOT NULL,
    "market_bucket" "text" NOT NULL,
    "detention_bucket" "text" NOT NULL,
    "backups_bucket" "text" NOT NULL,
    "assigned_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "assignment_version" integer DEFAULT 1 NOT NULL
);


ALTER TABLE "public"."user_storage_regions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_time_tracking" (
    "user_id" "uuid" NOT NULL,
    "epoch_day" bigint NOT NULL,
    "feature_key" "text" NOT NULL,
    "duration_seconds" bigint DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_time_tracking" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_folders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "name" "text" NOT NULL,
    "color" integer,
    "icon" "text",
    "parent_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_archived" boolean DEFAULT false NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb"
);


ALTER TABLE "public"."vault_folders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_invite_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invite_id" "uuid",
    "action" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "vault_invite_logs_action_check" CHECK (("action" = ANY (ARRAY['VIEW'::"text", 'DOWNLOAD'::"text", 'IMPORT'::"text"])))
);


ALTER TABLE "public"."vault_invite_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_item" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "file_id" "uuid" NOT NULL,
    "folder_id" "uuid",
    "title" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "tags" "text"[] DEFAULT '{}'::"text"[],
    "is_deleted" boolean DEFAULT false,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE ONLY "public"."vault_item" REPLICA IDENTITY FULL;


ALTER TABLE "public"."vault_item" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "file_id" "uuid" NOT NULL,
    "folder_id" "uuid",
    "title" "text" DEFAULT '[Encrypted]'::"text",
    "favorite" boolean DEFAULT false,
    "locked" boolean DEFAULT false,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "is_deleted" boolean DEFAULT false,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tags" "jsonb" DEFAULT '[]'::"jsonb",
    "is_archived" boolean DEFAULT false NOT NULL,
    "offline_status" "text" DEFAULT 'NONE'::"text",
    "offline_path" "text",
    "last_accessed_at" timestamp with time zone,
    CONSTRAINT "vault_items_offline_status_check" CHECK (("offline_status" = ANY (ARRAY['NONE'::"text", 'QUEUED'::"text", 'DOWNLOADING'::"text", 'AVAILABLE'::"text", 'FAILED'::"text"])))
);


ALTER TABLE "public"."vault_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_share_imports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "share_id" "uuid" NOT NULL,
    "recipient_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "total_items" integer DEFAULT 0,
    "processed_items" integer DEFAULT 0,
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "vault_share_imports_status_check" CHECK (("status" = ANY (ARRAY['PENDING'::"text", 'PROCESSING'::"text", 'COMPLETED'::"text", 'FAILED'::"text", 'CANCELLED'::"text"])))
);


ALTER TABLE "public"."vault_share_imports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_share_invite_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invite_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "item_type" "text" NOT NULL,
    "wrapped_fek" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "vault_share_invite_items_item_type_check" CHECK (("item_type" = ANY (ARRAY['FILE'::"text", 'FOLDER'::"text"])))
);


ALTER TABLE "public"."vault_share_invite_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_share_invites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "item_type" "text" NOT NULL,
    "token_hash" "text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone NOT NULL,
    "revoked_at" timestamp with time zone,
    "max_uses" integer DEFAULT 1,
    "use_count" integer DEFAULT 0,
    "wrapped_fek" "jsonb",
    "max_downloads" integer DEFAULT 100,
    "max_views" integer DEFAULT 1000,
    "total_downloads" integer DEFAULT 0,
    "total_views" integer DEFAULT 0,
    "is_multi" boolean DEFAULT false,
    CONSTRAINT "vault_share_invites_item_type_check" CHECK (("item_type" = ANY (ARRAY['FILE'::"text", 'FOLDER'::"text", 'MULTI'::"text"])))
);


ALTER TABLE "public"."vault_share_invites" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_share_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "share_id" "uuid",
    "action" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "vault_share_logs_action_check" CHECK (("action" = ANY (ARRAY['VIEW'::"text", 'DOWNLOAD'::"text"])))
);


ALTER TABLE "public"."vault_share_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vault_shares" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "wrapped_fek" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone NOT NULL,
    "is_revoked" boolean DEFAULT false,
    "max_downloads" integer DEFAULT 10,
    "download_count" integer DEFAULT 0
);


ALTER TABLE "public"."vault_shares" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "security_private"."recovery_seeds" (
    "user_id" "uuid" NOT NULL,
    "recovery_seed" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "security_private"."recovery_seeds" OWNER TO "postgres";


ALTER TABLE ONLY "public"."system_metrics" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."system_metrics_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."BIN_DB"
    ADD CONSTRAINT "BIN_DB_pkey" PRIMARY KEY ("BIN");



ALTER TABLE ONLY "public"."account_deletions"
    ADD CONSTRAINT "account_deletions_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."admin_users"
    ADD CONSTRAINT "admin_users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."admin_users"
    ADD CONSTRAINT "admin_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."agenda_attachment"
    ADD CONSTRAINT "agenda_attachment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ai_chat_settings"
    ADD CONSTRAINT "ai_chat_settings_pkey" PRIMARY KEY ("chat_id");



ALTER TABLE ONLY "public"."ai_credentials"
    ADD CONSTRAINT "ai_credentials_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ai_credentials"
    ADD CONSTRAINT "ai_credentials_user_id_provider_id_key" UNIQUE ("user_id", "provider_id");



ALTER TABLE ONLY "public"."ai_memories"
    ADD CONSTRAINT "ai_memories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ai_provider_configs"
    ADD CONSTRAINT "ai_provider_configs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."app_config"
    ADD CONSTRAINT "app_config_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."billing_audit_log"
    ADD CONSTRAINT "billing_audit_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."billing_balances"
    ADD CONSTRAINT "billing_balances_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."billing_invoices"
    ADD CONSTRAINT "billing_invoices_invoice_number_key" UNIQUE ("invoice_number");



ALTER TABLE ONLY "public"."billing_invoices"
    ADD CONSTRAINT "billing_invoices_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_idempotency_key_key" UNIQUE ("idempotency_key");



ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."billing_payments"
    ADD CONSTRAINT "billing_payments_idempotency_key_key" UNIQUE ("idempotency_key");



ALTER TABLE ONLY "public"."billing_payments"
    ADD CONSTRAINT "billing_payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."billing_payments"
    ADD CONSTRAINT "billing_payments_provider_transaction_id_key" UNIQUE ("provider_transaction_id");



ALTER TABLE ONLY "public"."billing_preferences"
    ADD CONSTRAINT "billing_preferences_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."billing_pricing"
    ADD CONSTRAINT "billing_pricing_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."billing_pricing"
    ADD CONSTRAINT "billing_pricing_version_name_key" UNIQUE ("version_name");



ALTER TABLE ONLY "public"."billing_usage"
    ADD CONSTRAINT "billing_usage_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocker_id_blocked_id_key" UNIQUE ("blocker_id", "blocked_id");



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_unique_pair" UNIQUE ("blocker_id", "blocked_id");



ALTER TABLE ONLY "public"."book_achievements"
    ADD CONSTRAINT "book_achievements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."book_bookmarks"
    ADD CONSTRAINT "book_bookmarks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_pkey" PRIMARY KEY ("book_id", "collection_id");



ALTER TABLE ONLY "public"."book_collections"
    ADD CONSTRAINT "book_collections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."book_progress"
    ADD CONSTRAINT "book_progress_pkey" PRIMARY KEY ("book_id");



ALTER TABLE ONLY "public"."book_quotes"
    ADD CONSTRAINT "book_quotes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."broadcasts"
    ADD CONSTRAINT "broadcasts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."browser_bookmarks"
    ADD CONSTRAINT "browser_bookmarks_pkey" PRIMARY KEY ("userId");



ALTER TABLE ONLY "public"."browser_history"
    ADD CONSTRAINT "browser_history_pkey" PRIMARY KEY ("userId");



ALTER TABLE ONLY "public"."bug_reports"
    ADD CONSTRAINT "bug_reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendar_categories"
    ADD CONSTRAINT "calendar_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendar_invitations"
    ADD CONSTRAINT "calendar_invitations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendar_items"
    ADD CONSTRAINT "calendar_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."call_logs"
    ADD CONSTRAINT "call_logs_pkey" PRIMARY KEY ("id", "user_id");



ALTER TABLE ONLY "public"."call_sessions"
    ADD CONSTRAINT "call_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."call_signaling"
    ADD CONSTRAINT "call_signaling_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."caller_contributions"
    ADD CONSTRAINT "caller_contributions_pkey" PRIMARY KEY ("contributor_user_id", "phone_hash", "field_type", "candidate_value");



ALTER TABLE ONLY "public"."caller_id_config"
    ADD CONSTRAINT "caller_id_config_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."caller_id_quotas"
    ADD CONSTRAINT "caller_id_quotas_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."caller_identities"
    ADD CONSTRAINT "caller_identities_pkey" PRIMARY KEY ("phone_hash");



ALTER TABLE ONLY "public"."caller_nicknames"
    ADD CONSTRAINT "caller_nicknames_pkey" PRIMARY KEY ("phone_hash", "nickname");



ALTER TABLE ONLY "public"."caller_spam_reporters"
    ADD CONSTRAINT "caller_spam_reporters_pkey" PRIMARY KEY ("user_id", "phone_hash");



ALTER TABLE ONLY "public"."chat_containers"
    ADD CONSTRAINT "chat_containers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_pkey" PRIMARY KEY ("chat_id", "user_id");



ALTER TABLE ONLY "public"."chat_reports"
    ADD CONSTRAINT "chat_reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chats"
    ADD CONSTRAINT "chats_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_pkey" PRIMARY KEY ("id", "owner_id");



ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_conversation_id_user_id_key" UNIQUE ("conversation_id", "user_id");



ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_user_id_conversation_id_key" UNIQUE ("user_id", "conversation_id");



ALTER TABLE ONLY "public"."data_exports"
    ADD CONSTRAINT "data_exports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."families"
    ADD CONSTRAINT "families_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."family_groups"
    ADD CONSTRAINT "family_groups_owner_id_key" UNIQUE ("owner_id");



ALTER TABLE ONLY "public"."family_groups"
    ADD CONSTRAINT "family_groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."family_permissions"
    ADD CONSTRAINT "family_permissions_family_member_id_type_key" UNIQUE ("family_member_id", "type");



ALTER TABLE ONLY "public"."family_permissions"
    ADD CONSTRAINT "family_permissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."feature_sync_plans"
    ADD CONSTRAINT "feature_sync_plans_feature_id_key" UNIQUE ("feature_id");



ALTER TABLE ONLY "public"."feature_sync_plans"
    ADD CONSTRAINT "feature_sync_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."habit_checkins"
    ADD CONSTRAINT "habit_checkins_habit_id_epoch_day_key" UNIQUE ("habit_id", "epoch_day");



ALTER TABLE ONLY "public"."habit_checkins"
    ADD CONSTRAINT "habit_checkins_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."habit_grace_uses"
    ADD CONSTRAINT "habit_grace_uses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."habit_logs"
    ADD CONSTRAINT "habit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."habit_milestones"
    ADD CONSTRAINT "habit_milestones_pkey" PRIMARY KEY ("user_id", "key");



ALTER TABLE ONLY "public"."habit_schedules"
    ADD CONSTRAINT "habit_schedules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."habits"
    ADD CONSTRAINT "habits_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."invitation_permissions"
    ADD CONSTRAINT "invitation_permissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."legal_documents"
    ADD CONSTRAINT "legal_documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."link_previews"
    ADD CONSTRAINT "link_previews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."login_attempts"
    ADD CONSTRAINT "login_attempts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_categories"
    ADD CONSTRAINT "market_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_favorites"
    ADD CONSTRAINT "market_favorites_pkey" PRIMARY KEY ("user_id", "listing_id");



ALTER TABLE ONLY "public"."market_listing_extensions"
    ADD CONSTRAINT "market_listing_extensions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_listing_media"
    ADD CONSTRAINT "market_listing_media_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_offers"
    ADD CONSTRAINT "market_offers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_reports"
    ADD CONSTRAINT "market_reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."market_saved"
    ADD CONSTRAINT "market_saved_pkey" PRIMARY KEY ("user_id", "listing_id");



ALTER TABLE ONLY "public"."market_sellers"
    ADD CONSTRAINT "market_sellers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."message_attachment"
    ADD CONSTRAINT "message_attachment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "message_link_previews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."message_reactions"
    ADD CONSTRAINT "message_reactions_message_id_user_id_key" UNIQUE ("message_id", "user_id");



ALTER TABLE ONLY "public"."message_reactions"
    ADD CONSTRAINT "message_reactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."message_requests"
    ADD CONSTRAINT "message_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."message_visibility"
    ADD CONSTRAINT "message_visibility_pkey" PRIMARY KEY ("message_id", "user_id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."note_attachment"
    ADD CONSTRAINT "note_attachment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."note_shares"
    ADD CONSTRAINT "note_shares_note_id_user_id_key" UNIQUE ("note_id", "user_id");



ALTER TABLE ONLY "public"."note_shares"
    ADD CONSTRAINT "note_shares_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notes"
    ADD CONSTRAINT "notes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notes_sync_queue"
    ADD CONSTRAINT "notes_sync_queue_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."official_broadcast_actions"
    ADD CONSTRAINT "official_broadcast_actions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "one_redemption_per_user_per_key" UNIQUE ("key_id", "user_id");



ALTER TABLE ONLY "public"."pinned_messages"
    ADD CONSTRAINT "pinned_messages_chat_id_message_id_key" UNIQUE ("chat_id", "message_id");



ALTER TABLE ONLY "public"."pinned_messages"
    ADD CONSTRAINT "pinned_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."premium_products_config"
    ADD CONSTRAINT "premium_products_config_pkey" PRIMARY KEY ("product_id");



ALTER TABLE ONLY "public"."profile_background_media"
    ADD CONSTRAINT "profile_background_media_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profile_views"
    ADD CONSTRAINT "profile_views_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reading_stats"
    ADD CONSTRAINT "reading_stats_pkey" PRIMARY KEY ("date", "user_id");



ALTER TABLE ONLY "public"."redeem_codes"
    ADD CONSTRAINT "redeem_codes_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."redeem_codes"
    ADD CONSTRAINT "redeem_codes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."redeem_history"
    ADD CONSTRAINT "redeem_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."relationship_intelligence"
    ADD CONSTRAINT "relationship_intelligence_pkey" PRIMARY KEY ("user_a", "user_b");



ALTER TABLE ONLY "public"."relationships"
    ADD CONSTRAINT "relationships_pkey" PRIMARY KEY ("user_id", "target_id");



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."secret_backup_codes"
    ADD CONSTRAINT "secret_backup_codes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."secret_credentials"
    ADD CONSTRAINT "secret_credentials_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."secret_password_history"
    ADD CONSTRAINT "secret_password_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."secret_settings"
    ADD CONSTRAINT "secret_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."secret_totp_accounts"
    ADD CONSTRAINT "secret_totp_accounts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."secret_vault_items"
    ADD CONSTRAINT "secret_vault_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."security_events"
    ADD CONSTRAINT "security_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sms_messages"
    ADD CONSTRAINT "sms_messages_pkey" PRIMARY KEY ("id", "user_id");



ALTER TABLE ONLY "public"."sms_threads"
    ADD CONSTRAINT "sms_threads_pkey" PRIMARY KEY ("id", "user_id");



ALTER TABLE ONLY "public"."storage_lifecycle_queue"
    ADD CONSTRAINT "storage_lifecycle_queue_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_device_install_requests"
    ADD CONSTRAINT "store_device_install_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_extensions"
    ADD CONSTRAINT "store_extensions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_extensions"
    ADD CONSTRAINT "store_extensions_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."store_installations"
    ADD CONSTRAINT "store_installations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_media_assets"
    ADD CONSTRAINT "store_media_assets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_publishers"
    ADD CONSTRAINT "store_publishers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_extension_user_key" UNIQUE ("extension_id", "user_id");



ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_releases"
    ADD CONSTRAINT "store_releases_extension_version_key" UNIQUE ("extension_id", "version");



ALTER TABLE ONLY "public"."store_releases"
    ADD CONSTRAINT "store_releases_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."store_submissions"
    ADD CONSTRAINT "store_submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "subscription_key_redemptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription_keys"
    ADD CONSTRAINT "subscription_keys_key_hash_key" UNIQUE ("key_hash");



ALTER TABLE ONLY "public"."subscription_keys"
    ADD CONSTRAINT "subscription_keys_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription_metadata"
    ADD CONSTRAINT "subscription_metadata_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_purchase_token_key" UNIQUE ("purchase_token");



ALTER TABLE ONLY "public"."system_metrics"
    ADD CONSTRAINT "system_metrics_metric_name_key" UNIQUE ("metric_name");



ALTER TABLE ONLY "public"."system_metrics"
    ADD CONSTRAINT "system_metrics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."todo_lists"
    ADD CONSTRAINT "todo_lists_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."todo_tasks"
    ADD CONSTRAINT "todo_tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."two_factor_login_challenges"
    ADD CONSTRAINT "two_factor_login_challenges_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."two_factor_login_challenges"
    ADD CONSTRAINT "two_factor_login_challenges_verification_token_key" UNIQUE ("verification_token");



ALTER TABLE ONLY "public"."two_factor_otp_challenges"
    ADD CONSTRAINT "two_factor_otp_challenges_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "unique_message_link_preview" UNIQUE ("message_id", "link_preview_id");



ALTER TABLE ONLY "public"."usage_sessions"
    ADD CONSTRAINT "usage_sessions_pkey" PRIMARY KEY ("session_id");



ALTER TABLE ONLY "public"."user_2fa_backup_codes"
    ADD CONSTRAINT "user_2fa_backup_codes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_2fa_factors"
    ADD CONSTRAINT "user_2fa_factors_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_2fa_factors"
    ADD CONSTRAINT "user_2fa_factors_user_id_factor_type_key" UNIQUE ("user_id", "factor_type");



ALTER TABLE ONLY "public"."user_app_customization"
    ADD CONSTRAINT "user_app_customization_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_book_bookmarks"
    ADD CONSTRAINT "user_book_bookmarks_pkey" PRIMARY KEY ("user_id", "book_id", "page_number");



ALTER TABLE ONLY "public"."user_book_highlights"
    ADD CONSTRAINT "user_book_highlights_pkey" PRIMARY KEY ("user_id", "id");



ALTER TABLE ONLY "public"."user_book_progress"
    ADD CONSTRAINT "user_book_progress_pkey" PRIMARY KEY ("user_id", "book_id", "page_number");



ALTER TABLE ONLY "public"."user_book_sessions"
    ADD CONSTRAINT "user_book_sessions_pkey" PRIMARY KEY ("user_id", "id");



ALTER TABLE ONLY "public"."user_book_settings"
    ADD CONSTRAINT "user_book_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_books"
    ADD CONSTRAINT "user_books_pkey" PRIMARY KEY ("user_id", "id");



ALTER TABLE ONLY "public"."user_broadcast_sync"
    ADD CONSTRAINT "user_broadcast_sync_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_bundles"
    ADD CONSTRAINT "user_bundles_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_chat_settings"
    ADD CONSTRAINT "user_chat_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_user_id_supervisor_id_key" UNIQUE ("user_id", "supervisor_id");



ALTER TABLE ONLY "public"."user_devices"
    ADD CONSTRAINT "user_devices_fcm_token_key" UNIQUE ("fcm_token");



ALTER TABLE ONLY "public"."user_devices"
    ADD CONSTRAINT "user_devices_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_doc_bookmarks"
    ADD CONSTRAINT "user_doc_bookmarks_pkey" PRIMARY KEY ("user_id", "doc_id", "page_or_position");



ALTER TABLE ONLY "public"."user_doc_highlights"
    ADD CONSTRAINT "user_doc_highlights_pkey" PRIMARY KEY ("user_id", "id");



ALTER TABLE ONLY "public"."user_doc_settings"
    ADD CONSTRAINT "user_doc_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_docs"
    ADD CONSTRAINT "user_docs_pkey" PRIMARY KEY ("user_id", "id");



ALTER TABLE ONLY "public"."user_drawings"
    ADD CONSTRAINT "user_drawings_pkey" PRIMARY KEY ("user_id", "id");



ALTER TABLE ONLY "public"."user_entitlements"
    ADD CONSTRAINT "user_entitlements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_feature_entitlements"
    ADD CONSTRAINT "user_feature_entitlements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_prekeys"
    ADD CONSTRAINT "user_prekeys_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_presence"
    ADD CONSTRAINT "user_presence_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_privacy_settings"
    ADD CONSTRAINT "user_privacy_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_reading_xp"
    ADD CONSTRAINT "user_reading_xp_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_recovery_seeds"
    ADD CONSTRAINT "user_recovery_seeds_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_security_settings"
    ADD CONSTRAINT "user_security_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_sessions"
    ADD CONSTRAINT "user_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_sessions"
    ADD CONSTRAINT "user_sessions_user_id_device_id_key" UNIQUE ("user_id", "device_id");



ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_storage_regions"
    ADD CONSTRAINT "user_storage_regions_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_time_tracking"
    ADD CONSTRAINT "user_time_tracking_pkey" PRIMARY KEY ("user_id", "epoch_day", "feature_key");



ALTER TABLE ONLY "public"."vault_folders"
    ADD CONSTRAINT "vault_folders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_invite_logs"
    ADD CONSTRAINT "vault_invite_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_items"
    ADD CONSTRAINT "vault_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_share_imports"
    ADD CONSTRAINT "vault_share_imports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_share_invite_items"
    ADD CONSTRAINT "vault_share_invite_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_share_invites"
    ADD CONSTRAINT "vault_share_invites_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_share_invites"
    ADD CONSTRAINT "vault_share_invites_token_hash_key" UNIQUE ("token_hash");



ALTER TABLE ONLY "public"."vault_share_logs"
    ADD CONSTRAINT "vault_share_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_shares"
    ADD CONSTRAINT "vault_shares_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vault_shares"
    ADD CONSTRAINT "vault_shares_token_key" UNIQUE ("token");



ALTER TABLE ONLY "security_private"."recovery_seeds"
    ADD CONSTRAINT "recovery_seeds_pkey" PRIMARY KEY ("user_id");



CREATE INDEX "chat_members_user_id_idx" ON "public"."chat_members" USING "btree" ("user_id");



CREATE INDEX "habit_checkins_habit_id_idx" ON "public"."habit_checkins" USING "btree" ("habit_id");



CREATE INDEX "habit_grace_uses_habit_id_idx" ON "public"."habit_grace_uses" USING "btree" ("habit_id");



CREATE INDEX "habit_logs_habit_id_idx" ON "public"."habit_logs" USING "btree" ("habit_id");



CREATE INDEX "habit_schedules_habit_id_idx" ON "public"."habit_schedules" USING "btree" ("habit_id");



CREATE INDEX "idx_billing_invoices_user" ON "public"."billing_invoices" USING "btree" ("user_id", "status");



CREATE INDEX "idx_billing_ledger_user" ON "public"."billing_ledger" USING "btree" ("user_id", "created_at");



CREATE INDEX "idx_billing_usage_user_period" ON "public"."billing_usage" USING "btree" ("user_id", "period_start", "period_end");



CREATE INDEX "idx_book_bookmarks_book_id" ON "public"."book_bookmarks" USING "btree" ("book_id");



CREATE INDEX "idx_book_quotes_book_id" ON "public"."book_quotes" USING "btree" ("book_id");



CREATE INDEX "idx_books_user_id" ON "public"."books" USING "btree" ("user_id");



CREATE INDEX "idx_books_vault_file_id" ON "public"."books" USING "btree" ("vault_file_id");



CREATE INDEX "idx_browser_bookmarks_user_id" ON "public"."browser_bookmarks" USING "btree" ("user_id");



CREATE INDEX "idx_browser_history_user_id" ON "public"."browser_history" USING "btree" ("user_id");



CREATE INDEX "idx_browser_history_visit_time" ON "public"."browser_history" USING "btree" ("visitTime" DESC);



CREATE INDEX "idx_call_signaling_call_id" ON "public"."call_signaling" USING "btree" ("call_id");



CREATE INDEX "idx_chat_members_last_delivered" ON "public"."chat_members" USING "btree" ("last_delivered_message_id");



CREATE INDEX "idx_chat_members_last_read" ON "public"."chat_members" USING "btree" ("last_read_message_id");



CREATE INDEX "idx_chat_members_user" ON "public"."chat_members" USING "btree" ("user_id");



CREATE INDEX "idx_chat_members_user_id_is_archived" ON "public"."chat_members" USING "btree" ("user_id", "is_archived");



CREATE INDEX "idx_chat_members_user_sync" ON "public"."chat_members" USING "btree" ("user_id", "is_pinned", "is_archived");



CREATE INDEX "idx_chats_last_activity_at" ON "public"."chats" USING "btree" ("last_activity_at" DESC);



CREATE INDEX "idx_chats_last_message_time" ON "public"."chats" USING "btree" ("last_message_time_ms" DESC);



CREATE INDEX "idx_contacts_owner_id" ON "public"."contacts" USING "btree" ("owner_id");



CREATE INDEX "idx_contacts_owner_search" ON "public"."contacts" USING "btree" ("owner_id", "is_keeftalk_user");



CREATE INDEX "idx_contacts_phone" ON "public"."contacts" USING "btree" ("phone");



CREATE INDEX "idx_family_groups_owner_id" ON "public"."family_groups" USING "btree" ("owner_id");



CREATE INDEX "idx_files_hash" ON "public"."files" USING "btree" ("file_hash");



CREATE INDEX "idx_files_owner" ON "public"."files" USING "btree" ("owner_id");



CREATE INDEX "idx_key_redemptions_user" ON "public"."subscription_key_redemptions" USING "btree" ("user_id");



CREATE UNIQUE INDEX "idx_link_previews_normalized_url" ON "public"."link_previews" USING "btree" ("normalized_url");



CREATE INDEX "idx_market_chats_buyer_id" ON "public"."market_chats" USING "btree" ("buyer_id");



CREATE INDEX "idx_market_chats_listing_id" ON "public"."market_chats" USING "btree" ("listing_id");



CREATE INDEX "idx_market_chats_seller_id" ON "public"."market_chats" USING "btree" ("seller_id");



CREATE INDEX "idx_market_listing_extensions_listing" ON "public"."market_listing_extensions" USING "btree" ("listing_id");



CREATE INDEX "idx_market_listings_cat" ON "public"."market_listings" USING "btree" ("cat");



CREATE INDEX "idx_market_listings_category" ON "public"."market_listings" USING "btree" ("category_id", "subcategory");



CREATE INDEX "idx_market_listings_created" ON "public"."market_listings" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_market_listings_exp" ON "public"."market_listings" USING "btree" ("exp");



CREATE INDEX "idx_market_listings_is_sold" ON "public"."market_listings" USING "btree" ("is_sold");



CREATE INDEX "idx_market_listings_location" ON "public"."market_listings" USING "btree" ("latitude", "longitude");



CREATE INDEX "idx_market_listings_price" ON "public"."market_listings" USING "btree" ("price");



CREATE INDEX "idx_market_listings_seller" ON "public"."market_listings" USING "btree" ("seller_id");



CREATE INDEX "idx_market_listings_status_expires" ON "public"."market_listings" USING "btree" ("status", "expires_at");



CREATE INDEX "idx_market_listings_user_id" ON "public"."market_listings" USING "btree" ("user_id");



CREATE INDEX "idx_market_media_listing" ON "public"."market_listing_media" USING "btree" ("listing_id");



CREATE INDEX "idx_market_offers_buyer" ON "public"."market_offers" USING "btree" ("buyer_id");



CREATE INDEX "idx_market_offers_listing" ON "public"."market_offers" USING "btree" ("listing_id");



CREATE INDEX "idx_message_reactions_message_id" ON "public"."message_reactions" USING "btree" ("message_id");



CREATE INDEX "idx_messages_chat_created" ON "public"."messages" USING "btree" ("chat_id", "created_at" DESC);



CREATE INDEX "idx_messages_chat_id_created_at" ON "public"."messages" USING "btree" ("chat_id", "created_at" DESC);



CREATE INDEX "idx_messages_chat_id_timestamp" ON "public"."messages" USING "btree" ("chat_id", "timestamp" DESC);



CREATE INDEX "idx_messages_chat_timestamp" ON "public"."messages" USING "btree" ("chat_id", "timestamp");



CREATE INDEX "idx_messages_media_lock" ON "public"."messages" USING "btree" ("media_locked");



CREATE INDEX "idx_messages_reply_to_id" ON "public"."messages" USING "btree" ("reply_to_id");



CREATE INDEX "idx_profile_views_viewed_created" ON "public"."profile_views" USING "btree" ("viewed_id", "created_at" DESC);



CREATE INDEX "idx_profiles_fcm_token" ON "public"."profiles" USING "btree" ("fcm_token") WHERE ("fcm_token" IS NOT NULL);



CREATE INDEX "idx_profiles_last_seen" ON "public"."profiles" USING "btree" ("last_seen");



CREATE INDEX "idx_profiles_total_xp" ON "public"."profiles" USING "btree" ("total_xp" DESC);



CREATE INDEX "idx_reading_sessions_book_id" ON "public"."reading_sessions" USING "btree" ("book_id");



CREATE INDEX "idx_reading_sessions_start_time" ON "public"."reading_sessions" USING "btree" ("start_time");



CREATE INDEX "idx_reading_sessions_user_id" ON "public"."reading_sessions" USING "btree" ("user_id");



CREATE INDEX "idx_relationship_intelligence_lookup" ON "public"."relationship_intelligence" USING "btree" ("user_a", "user_b");



CREATE INDEX "idx_secret_backup_codes_user" ON "public"."secret_backup_codes" USING "btree" ("user_id");



CREATE INDEX "idx_secret_credentials_cat" ON "public"."secret_credentials" USING "btree" ("category");



CREATE INDEX "idx_secret_credentials_user" ON "public"."secret_credentials" USING "btree" ("user_id");



CREATE INDEX "idx_secret_pw_hist_cred" ON "public"."secret_password_history" USING "btree" ("credential_id");



CREATE INDEX "idx_secret_pw_hist_user" ON "public"."secret_password_history" USING "btree" ("user_id");



CREATE INDEX "idx_secret_totp_user" ON "public"."secret_totp_accounts" USING "btree" ("user_id");



CREATE INDEX "idx_secret_vault_items_type" ON "public"."secret_vault_items" USING "btree" ("item_type");



CREATE INDEX "idx_secret_vault_items_user" ON "public"."secret_vault_items" USING "btree" ("user_id");



CREATE INDEX "idx_security_events_user_created" ON "public"."security_events" USING "btree" ("user_id", "created_at" DESC);



CREATE INDEX "idx_subscription_keys_hash" ON "public"."subscription_keys" USING "btree" ("key_hash");



CREATE INDEX "idx_todo_lists_user_id" ON "public"."todo_lists" USING "btree" ("user_id");



CREATE INDEX "idx_todo_tasks_user_id" ON "public"."todo_tasks" USING "btree" ("user_id");



CREATE INDEX "idx_usage_sessions_started_at" ON "public"."usage_sessions" USING "btree" ("started_at");



CREATE INDEX "idx_usage_sessions_user_id" ON "public"."usage_sessions" USING "btree" ("user_id");



CREATE INDEX "idx_user_book_bookmarks_user_book" ON "public"."user_book_bookmarks" USING "btree" ("user_id", "book_id");



CREATE INDEX "idx_user_book_highlights_user_book" ON "public"."user_book_highlights" USING "btree" ("user_id", "book_id");



CREATE INDEX "idx_user_book_progress_user_book" ON "public"."user_book_progress" USING "btree" ("user_id", "book_id");



CREATE INDEX "idx_user_book_sessions_user_book" ON "public"."user_book_sessions" USING "btree" ("user_id", "book_id");



CREATE INDEX "idx_user_books_updated_at" ON "public"."user_books" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_user_books_user_id" ON "public"."user_books" USING "btree" ("user_id");



CREATE INDEX "idx_user_doc_bookmarks_user_doc" ON "public"."user_doc_bookmarks" USING "btree" ("user_id", "doc_id");



CREATE INDEX "idx_user_doc_highlights_user_doc" ON "public"."user_doc_highlights" USING "btree" ("user_id", "doc_id");



CREATE INDEX "idx_user_docs_updated_at" ON "public"."user_docs" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_user_docs_user_id" ON "public"."user_docs" USING "btree" ("user_id");



CREATE INDEX "idx_user_drawings_is_deleted" ON "public"."user_drawings" USING "btree" ("is_deleted");



CREATE INDEX "idx_user_drawings_updated_at" ON "public"."user_drawings" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_user_drawings_user_id" ON "public"."user_drawings" USING "btree" ("user_id");



CREATE INDEX "idx_user_entitlements_user_status" ON "public"."user_entitlements" USING "btree" ("user_id", "status");



CREATE INDEX "idx_user_feature_entitlements_user_id" ON "public"."user_feature_entitlements" USING "btree" ("user_id");



CREATE INDEX "idx_user_reading_xp_total_xp" ON "public"."user_reading_xp" USING "btree" ("total_xp" DESC);



CREATE INDEX "idx_user_sessions_user_active" ON "public"."user_sessions" USING "btree" ("user_id", "last_active" DESC);



CREATE INDEX "idx_user_storage_regions_user_id" ON "public"."user_storage_regions" USING "btree" ("user_id");



CREATE INDEX "idx_vault_folders_parent_id" ON "public"."vault_folders" USING "btree" ("parent_id");



CREATE INDEX "idx_vault_invite_logs_invite_id" ON "public"."vault_invite_logs" USING "btree" ("invite_id");



CREATE INDEX "idx_vault_items_folder_id" ON "public"."vault_items" USING "btree" ("folder_id");



CREATE INDEX "idx_vault_share_imports_recipient_id" ON "public"."vault_share_imports" USING "btree" ("recipient_id");



CREATE INDEX "idx_vault_share_imports_share_id" ON "public"."vault_share_imports" USING "btree" ("share_id");



CREATE INDEX "idx_vault_share_invite_items_invite_id" ON "public"."vault_share_invite_items" USING "btree" ("invite_id");



CREATE INDEX "idx_vault_share_invites_sender_id" ON "public"."vault_share_invites" USING "btree" ("sender_id");



CREATE INDEX "idx_vault_share_invites_token_hash" ON "public"."vault_share_invites" USING "btree" ("token_hash");



CREATE INDEX "idx_vault_share_logs_share_time" ON "public"."vault_share_logs" USING "btree" ("share_id", "created_at");



CREATE INDEX "idx_vault_shares_item_id" ON "public"."vault_shares" USING "btree" ("item_id");



CREATE INDEX "idx_vault_shares_token" ON "public"."vault_shares" USING "btree" ("token");



CREATE INDEX "idx_vault_shares_user_id" ON "public"."vault_shares" USING "btree" ("user_id");



CREATE INDEX "notes_owner_id_idx" ON "public"."notes" USING "btree" ("owner_id");



CREATE INDEX "notes_owner_updated_idx" ON "public"."notes" USING "btree" ("owner_id", "updated_at");



CREATE INDEX "notes_updated_at_idx" ON "public"."notes" USING "btree" ("updated_at");



CREATE UNIQUE INDEX "one_active_document_per_type" ON "public"."legal_documents" USING "btree" ("type") WHERE ("is_active" = true);



CREATE INDEX "profiles_full_name_idx" ON "public"."profiles" USING "gin" ("full_name" "public"."gin_trgm_ops");



CREATE INDEX "profiles_username_idx" ON "public"."profiles" USING "gin" ("username" "public"."gin_trgm_ops");



CREATE INDEX "user_sessions_lookup_idx" ON "public"."user_sessions" USING "btree" ("user_id", "device_id");



CREATE OR REPLACE TRIGGER "before_file_insert" BEFORE INSERT ON "public"."files" FOR EACH ROW EXECUTE FUNCTION "public"."check_file_upload_limits"();



CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."call_sessions" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');



CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."message_reactions" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');



CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');



CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');



CREATE OR REPLACE TRIGGER "fcmmsg" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_contacts_update" BEFORE UPDATE ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "on_entitlement_change" AFTER INSERT OR DELETE OR UPDATE ON "public"."user_entitlements" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_active_benefits"();



CREATE OR REPLACE TRIGGER "on_file_change" AFTER INSERT OR DELETE OR UPDATE ON "public"."files" FOR EACH ROW EXECUTE FUNCTION "public"."update_profile_storage_usage"();



CREATE OR REPLACE TRIGGER "on_message_inserted" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_message"();



CREATE OR REPLACE TRIGGER "on_message_inserted_sync_chat" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_message_sync"();



CREATE OR REPLACE TRIGGER "on_message_sent" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/smart-task', 'POST', '{"Content-Type":"application/json", "Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}');



CREATE OR REPLACE TRIGGER "on_profile_created_init_customization" AFTER INSERT ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."initialize_user_customization"();



CREATE OR REPLACE TRIGGER "on_profile_view" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "public"."handle_profile_view_notification"();



CREATE OR REPLACE TRIGGER "on_security_event" AFTER INSERT ON "public"."security_events" FOR EACH ROW EXECUTE FUNCTION "public"."handle_security_event_notification"();



CREATE OR REPLACE TRIGGER "on_sms_threads_update" BEFORE UPDATE ON "public"."sms_threads" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "on_user_app_customization_update" BEFORE UPDATE ON "public"."user_app_customization" FOR EACH ROW EXECUTE FUNCTION "public"."handle_app_customization_updated_at"();



CREATE OR REPLACE TRIGGER "on_user_settings_parental_protection" BEFORE UPDATE ON "public"."user_settings" FOR EACH ROW EXECUTE FUNCTION "public"."protect_parental_controls"();



CREATE OR REPLACE TRIGGER "on_user_settings_update" BEFORE UPDATE ON "public"."user_settings" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "on_visibility_updated" BEFORE UPDATE ON "public"."message_visibility" FOR EACH ROW EXECUTE FUNCTION "public"."handle_visibility_updated_at"();



CREATE OR REPLACE TRIGGER "set_updated_at" BEFORE UPDATE ON "public"."user_app_customization" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_call_session_change" AFTER INSERT OR UPDATE ON "public"."call_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_message_insert" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_note_share_insert" AFTER INSERT ON "public"."note_shares" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_notification_insert" AFTER INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_profile_view_insert" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_reaction_insert" AFTER INSERT ON "public"."message_reactions" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_fcm_on_vault_share_insert" AFTER INSERT ON "public"."vault_shares" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();



CREATE OR REPLACE TRIGGER "tr_handle_new_profile_privacy" AFTER INSERT ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_profile_privacy"();



CREATE OR REPLACE TRIGGER "tr_message_sent_update_strength" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."on_message_update_relationship_strength"();



CREATE OR REPLACE TRIGGER "tr_notify_security_event" AFTER INSERT ON "public"."security_events" FOR EACH ROW EXECUTE FUNCTION "public"."notify_security_event"();



CREATE OR REPLACE TRIGGER "tr_notify_session_revoked" AFTER DELETE ON "public"."user_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."notify_session_revoked"();



CREATE OR REPLACE TRIGGER "tr_official_broadcast_sync" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."on_official_message_sent"();



CREATE OR REPLACE TRIGGER "tr_on_new_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."notify_new_message"();



CREATE OR REPLACE TRIGGER "tr_on_profile_view_insert" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "public"."increment_profile_view_count"();



CREATE OR REPLACE TRIGGER "tr_profile_phone_hmac" BEFORE INSERT OR UPDATE OF "phone" ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_profile_phone_hmac"();



CREATE OR REPLACE TRIGGER "tr_ref_count_agenda" AFTER INSERT OR DELETE ON "public"."agenda_attachment" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();



CREATE OR REPLACE TRIGGER "tr_ref_count_chat" AFTER INSERT OR DELETE ON "public"."message_attachment" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();



CREATE OR REPLACE TRIGGER "tr_ref_count_note" AFTER INSERT OR DELETE ON "public"."note_attachment" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();



CREATE OR REPLACE TRIGGER "tr_ref_count_vault" AFTER INSERT OR DELETE ON "public"."vault_item" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();



CREATE OR REPLACE TRIGGER "tr_sync_chat_last_message" AFTER INSERT OR UPDATE OF "status" ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."sync_chat_last_message"();



CREATE OR REPLACE TRIGGER "tr_sync_chat_status_from_pointers" AFTER UPDATE OF "last_read_message_id", "last_delivered_message_id" ON "public"."chat_members" FOR EACH ROW EXECUTE FUNCTION "public"."sync_chat_status_from_pointers"();



CREATE OR REPLACE TRIGGER "tr_team_member_upgrade" BEFORE INSERT OR UPDATE OF "email" ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_team_member_upgrade"();



CREATE OR REPLACE TRIGGER "tr_update_chat_on_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."handle_message_sync_update"();



CREATE OR REPLACE TRIGGER "tr_user_privacy_settings_updated_at" BEFORE UPDATE ON "public"."user_privacy_settings" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "tr_vault_import_started" AFTER INSERT ON "public"."vault_share_imports" FOR EACH ROW EXECUTE FUNCTION "public"."on_vault_import_started"();



CREATE OR REPLACE TRIGGER "trg_store_install_stats" AFTER INSERT ON "public"."store_installations" FOR EACH ROW EXECUTE FUNCTION "public"."update_extension_install_stats"();



CREATE OR REPLACE TRIGGER "trg_store_rating_stats" AFTER INSERT OR DELETE OR UPDATE ON "public"."store_ratings" FOR EACH ROW EXECUTE FUNCTION "public"."update_extension_rating_stats"();



CREATE OR REPLACE TRIGGER "trigger_name_change_cooldown" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_name_change_cooldown"();



CREATE OR REPLACE TRIGGER "trigger_update_chat_last_activity" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_chat_last_activity"();



CREATE OR REPLACE TRIGGER "trigger_validate_background_media" BEFORE INSERT OR UPDATE ON "public"."profile_background_media" FOR EACH ROW EXECUTE FUNCTION "public"."validate_background_media"();



CREATE OR REPLACE TRIGGER "update_book_achievements_updated_at" BEFORE UPDATE ON "public"."book_achievements" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_book_bookmarks_updated_at" BEFORE UPDATE ON "public"."book_bookmarks" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_book_collection_ref_updated_at" BEFORE UPDATE ON "public"."book_collection_ref" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_book_collections_updated_at" BEFORE UPDATE ON "public"."book_collections" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_book_progress_updated_at" BEFORE UPDATE ON "public"."book_progress" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_book_quotes_updated_at" BEFORE UPDATE ON "public"."book_quotes" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_books_updated_at" BEFORE UPDATE ON "public"."books" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_files_updated_at" BEFORE UPDATE ON "public"."files" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_market_chats_updated_at" BEFORE UPDATE ON "public"."market_chats" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_market_listings_updated_at" BEFORE UPDATE ON "public"."market_listings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_market_sellers_updated_at" BEFORE UPDATE ON "public"."market_sellers" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_notes_updated_at" BEFORE UPDATE ON "public"."notes" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_reading_stats_updated_at" BEFORE UPDATE ON "public"."reading_stats" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_user_chat_settings_updated_at" BEFORE UPDATE ON "public"."user_chat_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_user_security_settings_updated_at" BEFORE UPDATE ON "public"."user_security_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."admin_users"
    ADD CONSTRAINT "admin_users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."agenda_attachment"
    ADD CONSTRAINT "agenda_attachment_agenda_event_id_fkey" FOREIGN KEY ("agenda_event_id") REFERENCES "public"."calendar_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."agenda_attachment"
    ADD CONSTRAINT "agenda_attachment_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");



ALTER TABLE ONLY "public"."ai_chat_settings"
    ADD CONSTRAINT "ai_chat_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ai_credentials"
    ADD CONSTRAINT "ai_credentials_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ai_memories"
    ADD CONSTRAINT "ai_memories_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ai_provider_configs"
    ADD CONSTRAINT "ai_provider_configs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."billing_audit_log"
    ADD CONSTRAINT "billing_audit_log_pricing_version_id_fkey" FOREIGN KEY ("pricing_version_id") REFERENCES "public"."billing_pricing"("id");



ALTER TABLE ONLY "public"."billing_balances"
    ADD CONSTRAINT "billing_balances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."billing_invoices"
    ADD CONSTRAINT "billing_invoices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_pricing_version_id_fkey" FOREIGN KEY ("pricing_version_id") REFERENCES "public"."billing_pricing"("id");



ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."billing_payments"
    ADD CONSTRAINT "billing_payments_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "public"."billing_invoices"("id");



ALTER TABLE ONLY "public"."billing_payments"
    ADD CONSTRAINT "billing_payments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."billing_preferences"
    ADD CONSTRAINT "billing_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."billing_usage"
    ADD CONSTRAINT "billing_usage_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocked_id_fkey" FOREIGN KEY ("blocked_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocker_id_fkey" FOREIGN KEY ("blocker_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_achievements"
    ADD CONSTRAINT "book_achievements_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_achievements"
    ADD CONSTRAINT "book_achievements_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_bookmarks"
    ADD CONSTRAINT "book_bookmarks_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_bookmarks"
    ADD CONSTRAINT "book_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_collection_id_fkey" FOREIGN KEY ("collection_id") REFERENCES "public"."book_collections"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_collections"
    ADD CONSTRAINT "book_collections_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_progress"
    ADD CONSTRAINT "book_progress_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_progress"
    ADD CONSTRAINT "book_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_quotes"
    ADD CONSTRAINT "book_quotes_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_quotes"
    ADD CONSTRAINT "book_quotes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_vault_file_id_fkey" FOREIGN KEY ("vault_file_id") REFERENCES "public"."vault_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."browser_bookmarks"
    ADD CONSTRAINT "browser_bookmarks_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."browser_bookmarks"("userId");



ALTER TABLE ONLY "public"."browser_bookmarks"
    ADD CONSTRAINT "browser_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."browser_history"
    ADD CONSTRAINT "browser_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bug_reports"
    ADD CONSTRAINT "bug_reports_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."calendar_categories"
    ADD CONSTRAINT "calendar_categories_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_invitations"
    ADD CONSTRAINT "calendar_invitations_from_user_id_fkey" FOREIGN KEY ("from_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_invitations"
    ADD CONSTRAINT "calendar_invitations_to_user_id_fkey" FOREIGN KEY ("to_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_items"
    ADD CONSTRAINT "calendar_items_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_items"
    ADD CONSTRAINT "calendar_items_parent_item_id_fkey" FOREIGN KEY ("parent_item_id") REFERENCES "public"."calendar_items"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."call_logs"
    ADD CONSTRAINT "call_logs_peer_id_fkey" FOREIGN KEY ("peer_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."call_logs"
    ADD CONSTRAINT "call_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."call_sessions"
    ADD CONSTRAINT "call_sessions_caller_id_fkey" FOREIGN KEY ("caller_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."call_sessions"
    ADD CONSTRAINT "call_sessions_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."call_sessions"
    ADD CONSTRAINT "call_sessions_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."call_signaling"
    ADD CONSTRAINT "call_signaling_call_id_fkey" FOREIGN KEY ("call_id") REFERENCES "public"."call_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."call_signaling"
    ADD CONSTRAINT "call_signaling_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."caller_contributions"
    ADD CONSTRAINT "caller_contributions_contributor_user_id_fkey" FOREIGN KEY ("contributor_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."caller_id_quotas"
    ADD CONSTRAINT "caller_id_quotas_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."caller_spam_reporters"
    ADD CONSTRAINT "caller_spam_reporters_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_containers"
    ADD CONSTRAINT "chat_containers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_last_delivered_message_id_fkey" FOREIGN KEY ("last_delivered_message_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_last_read_message_id_fkey" FOREIGN KEY ("last_read_message_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_reports"
    ADD CONSTRAINT "chat_reports_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id");



ALTER TABLE ONLY "public"."chat_reports"
    ADD CONSTRAINT "chat_reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."families"
    ADD CONSTRAINT "families_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."habit_checkins"
    ADD CONSTRAINT "habit_checkins_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."habit_grace_uses"
    ADD CONSTRAINT "habit_grace_uses_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."habit_logs"
    ADD CONSTRAINT "habit_logs_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."habit_milestones"
    ADD CONSTRAINT "habit_milestones_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."habit_schedules"
    ADD CONSTRAINT "habit_schedules_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."habits"
    ADD CONSTRAINT "habits_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invitation_permissions"
    ADD CONSTRAINT "invitation_permissions_invitation_id_fkey" FOREIGN KEY ("invitation_id") REFERENCES "public"."calendar_invitations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."login_attempts"
    ADD CONSTRAINT "login_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_seller_id_fkey" FOREIGN KEY ("seller_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_favorites"
    ADD CONSTRAINT "market_favorites_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_favorites"
    ADD CONSTRAINT "market_favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_listing_extensions"
    ADD CONSTRAINT "market_listing_extensions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_listing_media"
    ADD CONSTRAINT "market_listing_media_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."market_categories"("id");



ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_seller_id_fkey" FOREIGN KEY ("seller_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_offers"
    ADD CONSTRAINT "market_offers_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_offers"
    ADD CONSTRAINT "market_offers_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_reports"
    ADD CONSTRAINT "market_reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_saved"
    ADD CONSTRAINT "market_saved_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_saved"
    ADD CONSTRAINT "market_saved_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."market_sellers"
    ADD CONSTRAINT "market_sellers_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_attachment"
    ADD CONSTRAINT "message_attachment_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");



ALTER TABLE ONLY "public"."message_attachment"
    ADD CONSTRAINT "message_attachment_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "message_link_previews_link_preview_id_fkey" FOREIGN KEY ("link_preview_id") REFERENCES "public"."link_previews"("id");



ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "message_link_previews_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_reactions"
    ADD CONSTRAINT "message_reactions_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_reactions"
    ADD CONSTRAINT "message_reactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_requests"
    ADD CONSTRAINT "message_requests_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_requests"
    ADD CONSTRAINT "message_requests_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."message_visibility"
    ADD CONSTRAINT "message_visibility_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_media_lock_updated_by_fkey" FOREIGN KEY ("media_lock_updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_reply_to_id_fkey" FOREIGN KEY ("reply_to_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."note_attachment"
    ADD CONSTRAINT "note_attachment_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");



ALTER TABLE ONLY "public"."note_attachment"
    ADD CONSTRAINT "note_attachment_note_id_fkey" FOREIGN KEY ("note_id") REFERENCES "public"."notes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."note_shares"
    ADD CONSTRAINT "note_shares_note_id_fkey" FOREIGN KEY ("note_id") REFERENCES "public"."notes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."note_shares"
    ADD CONSTRAINT "note_shares_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notes"
    ADD CONSTRAINT "notes_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."official_broadcast_actions"
    ADD CONSTRAINT "official_broadcast_actions_broadcast_id_fkey" FOREIGN KEY ("broadcast_id") REFERENCES "public"."broadcasts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pinned_messages"
    ADD CONSTRAINT "pinned_messages_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pinned_messages"
    ADD CONSTRAINT "pinned_messages_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pinned_messages"
    ADD CONSTRAINT "pinned_messages_pinned_by_fkey" FOREIGN KEY ("pinned_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profile_views"
    ADD CONSTRAINT "profile_views_viewed_id_fkey" FOREIGN KEY ("viewed_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_views"
    ADD CONSTRAINT "profile_views_viewer_id_fkey" FOREIGN KEY ("viewer_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_family_id_fkey" FOREIGN KEY ("family_id") REFERENCES "public"."families"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reading_stats"
    ADD CONSTRAINT "reading_stats_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."redeem_history"
    ADD CONSTRAINT "redeem_history_code_id_fkey" FOREIGN KEY ("code_id") REFERENCES "public"."redeem_codes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."redeem_history"
    ADD CONSTRAINT "redeem_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."relationships"
    ADD CONSTRAINT "relationships_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."relationships"
    ADD CONSTRAINT "relationships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reported_user_id_fkey" FOREIGN KEY ("reported_user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."secret_backup_codes"
    ADD CONSTRAINT "secret_backup_codes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."secret_credentials"
    ADD CONSTRAINT "secret_credentials_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."secret_password_history"
    ADD CONSTRAINT "secret_password_history_credential_id_fkey" FOREIGN KEY ("credential_id") REFERENCES "public"."secret_credentials"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."secret_password_history"
    ADD CONSTRAINT "secret_password_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."secret_settings"
    ADD CONSTRAINT "secret_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."secret_totp_accounts"
    ADD CONSTRAINT "secret_totp_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."secret_vault_items"
    ADD CONSTRAINT "secret_vault_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."security_events"
    ADD CONSTRAINT "security_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sms_messages"
    ADD CONSTRAINT "sms_messages_thread_id_fkey" FOREIGN KEY ("thread_id", "user_id") REFERENCES "public"."sms_threads"("id", "user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sms_messages"
    ADD CONSTRAINT "sms_messages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sms_threads"
    ADD CONSTRAINT "sms_threads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_device_install_requests"
    ADD CONSTRAINT "store_device_install_requests_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_device_install_requests"
    ADD CONSTRAINT "store_device_install_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_extensions"
    ADD CONSTRAINT "store_extensions_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "public"."store_publishers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_installations"
    ADD CONSTRAINT "store_installations_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_installations"
    ADD CONSTRAINT "store_installations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_media_assets"
    ADD CONSTRAINT "store_media_assets_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_publishers"
    ADD CONSTRAINT "store_publishers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_releases"
    ADD CONSTRAINT "store_releases_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."store_submissions"
    ADD CONSTRAINT "store_submissions_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "public"."store_publishers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "subscription_key_redemptions_key_id_fkey" FOREIGN KEY ("key_id") REFERENCES "public"."subscription_keys"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "subscription_key_redemptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscription_keys"
    ADD CONSTRAINT "subscription_keys_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."todo_lists"
    ADD CONSTRAINT "todo_lists_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."todo_tasks"
    ADD CONSTRAINT "todo_tasks_list_id_fkey" FOREIGN KEY ("list_id") REFERENCES "public"."todo_lists"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."todo_tasks"
    ADD CONSTRAINT "todo_tasks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."two_factor_login_challenges"
    ADD CONSTRAINT "two_factor_login_challenges_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."two_factor_otp_challenges"
    ADD CONSTRAINT "two_factor_otp_challenges_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."usage_sessions"
    ADD CONSTRAINT "usage_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_2fa_backup_codes"
    ADD CONSTRAINT "user_2fa_backup_codes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_2fa_factors"
    ADD CONSTRAINT "user_2fa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_app_customization"
    ADD CONSTRAINT "user_app_customization_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_book_bookmarks"
    ADD CONSTRAINT "user_book_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_book_highlights"
    ADD CONSTRAINT "user_book_highlights_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_book_progress"
    ADD CONSTRAINT "user_book_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_book_sessions"
    ADD CONSTRAINT "user_book_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_book_settings"
    ADD CONSTRAINT "user_book_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_books"
    ADD CONSTRAINT "user_books_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_bundles"
    ADD CONSTRAINT "user_bundles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_chat_settings"
    ADD CONSTRAINT "user_chat_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_supervisor_id_fkey" FOREIGN KEY ("supervisor_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_devices"
    ADD CONSTRAINT "user_devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_doc_bookmarks"
    ADD CONSTRAINT "user_doc_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_doc_highlights"
    ADD CONSTRAINT "user_doc_highlights_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_doc_settings"
    ADD CONSTRAINT "user_doc_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_docs"
    ADD CONSTRAINT "user_docs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_drawings"
    ADD CONSTRAINT "user_drawings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_entitlements"
    ADD CONSTRAINT "user_entitlements_source_key_id_fkey" FOREIGN KEY ("source_key_id") REFERENCES "public"."subscription_keys"("id");



ALTER TABLE ONLY "public"."user_entitlements"
    ADD CONSTRAINT "user_entitlements_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_prekeys"
    ADD CONSTRAINT "user_prekeys_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_presence"
    ADD CONSTRAINT "user_presence_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_privacy_settings"
    ADD CONSTRAINT "user_privacy_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_reading_xp"
    ADD CONSTRAINT "user_reading_xp_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_recovery_seeds"
    ADD CONSTRAINT "user_recovery_seeds_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_security_settings"
    ADD CONSTRAINT "user_security_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_sessions"
    ADD CONSTRAINT "user_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_storage_regions"
    ADD CONSTRAINT "user_storage_regions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_time_tracking"
    ADD CONSTRAINT "user_time_tracking_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_folders"
    ADD CONSTRAINT "vault_folders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_invite_logs"
    ADD CONSTRAINT "vault_invite_logs_invite_id_fkey" FOREIGN KEY ("invite_id") REFERENCES "public"."vault_share_invites"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");



ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_folder_id_fkey" FOREIGN KEY ("folder_id") REFERENCES "public"."vault_folders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."vault_items"
    ADD CONSTRAINT "vault_items_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_items"
    ADD CONSTRAINT "vault_items_folder_id_fkey" FOREIGN KEY ("folder_id") REFERENCES "public"."vault_folders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."vault_share_imports"
    ADD CONSTRAINT "vault_share_imports_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_share_imports"
    ADD CONSTRAINT "vault_share_imports_share_id_fkey" FOREIGN KEY ("share_id") REFERENCES "public"."vault_share_invites"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_share_invite_items"
    ADD CONSTRAINT "vault_share_invite_items_invite_id_fkey" FOREIGN KEY ("invite_id") REFERENCES "public"."vault_share_invites"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_share_invites"
    ADD CONSTRAINT "vault_share_invites_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_share_logs"
    ADD CONSTRAINT "vault_share_logs_share_id_fkey" FOREIGN KEY ("share_id") REFERENCES "public"."vault_shares"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vault_shares"
    ADD CONSTRAINT "vault_shares_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."vault_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "security_private"."recovery_seeds"
    ADD CONSTRAINT "recovery_seeds_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Admins can add members" ON "public"."chat_members" FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."chat_members" "chat_members_1"
  WHERE (("chat_members_1"."chat_id" = "chat_members_1"."chat_id") AND ("chat_members_1"."user_id" = "auth"."uid"()) AND ("chat_members_1"."role" = 'admin'::"text")))) OR ("auth"."uid"() = "user_id")));



CREATE POLICY "Admins can manage keys" ON "public"."subscription_keys" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));



CREATE POLICY "Admins can read all messages" ON "public"."messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admin_users"
  WHERE ("admin_users"."id" = "auth"."uid"()))));



CREATE POLICY "Admins can read all presence" ON "public"."user_presence" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admin_users"
  WHERE ("admin_users"."id" = "auth"."uid"()))));



CREATE POLICY "Admins can read system metrics" ON "public"."system_metrics" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admin_users"
  WHERE ("admin_users"."id" = "auth"."uid"()))));



CREATE POLICY "Allow call creation by caller" ON "public"."call_sessions" FOR INSERT TO "authenticated" WITH CHECK (("caller_id" = "auth"."uid"()));



CREATE POLICY "Allow call read for participants" ON "public"."call_sessions" FOR SELECT TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "Allow call updates for participants" ON "public"."call_sessions" FOR UPDATE TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"()))) WITH CHECK ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "Allow public read" ON "public"."subscription_metadata" FOR SELECT TO "anon", "authenticated" USING (true);



CREATE POLICY "Allow public read access for subscription plans" ON "public"."subscription_metadata" FOR SELECT TO "anon" USING (true);



CREATE POLICY "Allow public read for active documents" ON "public"."legal_documents" FOR SELECT TO "anon", "authenticated" USING (("is_active" = true));



CREATE POLICY "Allow public read of link previews" ON "public"."link_previews" FOR SELECT USING (true);



CREATE POLICY "Allow read access to BIN_DB" ON "public"."BIN_DB" FOR SELECT TO "anon", "authenticated" USING (true);



CREATE POLICY "Allow read of message link previews for participants" ON "public"."message_link_previews" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."messages" "m"
     JOIN "public"."chat_members" "cm" ON (("m"."chat_id" = "cm"."chat_id")))
  WHERE (("m"."id" = "message_link_previews"."message_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Allow service role to manage all associations" ON "public"."message_link_previews" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));



CREATE POLICY "Allow service role to manage message associations" ON "public"."message_link_previews" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));



CREATE POLICY "Allow service role to manage previews" ON "public"."link_previews" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));



CREATE POLICY "Allow users to insert their own message link previews" ON "public"."message_link_previews" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."messages"
  WHERE (("messages"."id" = "message_link_previews"."message_id") AND ("messages"."sender_id" = "auth"."uid"())))));



CREATE POLICY "Anyone can read app_config" ON "public"."app_config" FOR SELECT TO "anon", "authenticated" USING (true);



CREATE POLICY "Anyone insert installations" ON "public"."store_installations" FOR INSERT WITH CHECK (true);



CREATE POLICY "Anyone insert ratings" ON "public"."store_ratings" FOR INSERT WITH CHECK (true);



CREATE POLICY "Authenticated users can read billing pricing" ON "public"."billing_pricing" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "Authenticated users can read broadcasts" ON "public"."broadcasts" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read global XP leaderboard" ON "public"."user_reading_xp" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users create listing" ON "public"."market_listings" FOR INSERT WITH CHECK (("auth"."uid"() = "seller_id"));



CREATE POLICY "Authenticated users insert categories" ON "public"."market_categories" FOR INSERT WITH CHECK (true);



ALTER TABLE "public"."BIN_DB" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Buyers create offer" ON "public"."market_offers" FOR INSERT WITH CHECK (("auth"."uid"() = "buyer_id"));



CREATE POLICY "Chat members can pin messages" ON "public"."pinned_messages" USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = ("pinned_messages"."chat_id")::"text") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Chat members can read conversation keys" ON "public"."conversation_keys" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = "conversation_keys"."conversation_id") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Chat members can view attachments" ON "public"."message_attachment" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."messages" "m"
     JOIN "public"."chat_members" "cm" ON ((("m"."chat_id")::"text" = ("cm"."chat_id")::"text")))
  WHERE ((("m"."id")::"text" = ("message_attachment"."message_id")::"text") AND (("cm"."user_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Chat members can view pinned messages" ON "public"."pinned_messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = ("pinned_messages"."chat_id")::"text") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Enable read access for all users" ON "public"."subscription_metadata" FOR SELECT TO "anon" USING (true);



CREATE POLICY "Internal Access Only" ON "public"."caller_contributions" USING (false);



CREATE POLICY "Internal Access Only" ON "public"."caller_id_quotas" USING (false);



CREATE POLICY "Internal Access Only" ON "public"."caller_identities" USING (false);



CREATE POLICY "Internal Access Only" ON "public"."caller_nicknames" USING (false);



CREATE POLICY "Internal Access Only" ON "public"."caller_spam_reporters" USING (false);



CREATE POLICY "Involved users update offer" ON "public"."market_offers" FOR UPDATE USING ((("auth"."uid"() = "buyer_id") OR (EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_offers"."listing_id") AND ("l"."seller_id" = "auth"."uid"()))))));



CREATE POLICY "Lifecycle queue is backend only" ON "public"."storage_lifecycle_queue" TO "service_role" USING (true);



CREATE POLICY "Official users can read analytics" ON "public"."official_broadcast_actions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_official" = true)))));



CREATE POLICY "Owners can manage their files" ON "public"."files" USING ((("auth"."uid"())::"text" = ("owner_id")::"text"));



CREATE POLICY "Parents can update child settings" ON "public"."user_settings" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."families" "f"
     JOIN "public"."profiles" "p" ON (("p"."family_id" = "f"."id")))
  WHERE ((("f"."owner_id")::"text" = ("auth"."uid"())::"text") AND (("p"."id")::"text" = ("user_settings"."user_id")::"text"))))) WITH CHECK (true);



CREATE POLICY "Parents can view child settings" ON "public"."user_settings" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."families" "f"
     JOIN "public"."profiles" "p" ON (("p"."family_id" = "f"."id")))
  WHERE ((("f"."owner_id")::"text" = ("auth"."uid"())::"text") AND (("p"."id")::"text" = ("user_settings"."user_id")::"text")))));



CREATE POLICY "Participants can insert market_chats" ON "public"."market_chats" FOR INSERT WITH CHECK (((("auth"."uid"())::"text" = ("buyer_id")::"text") OR (("auth"."uid"())::"text" = ("seller_id")::"text")));



CREATE POLICY "Participants can update call state" ON "public"."call_sessions" FOR UPDATE TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"()))) WITH CHECK ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "Participants can update market_chats" ON "public"."market_chats" FOR UPDATE USING (((("auth"."uid"())::"text" = ("buyer_id")::"text") OR (("auth"."uid"())::"text" = ("seller_id")::"text")));



CREATE POLICY "Participants can view market_chats" ON "public"."market_chats" FOR SELECT USING (((("auth"."uid"())::"text" = ("buyer_id")::"text") OR (("auth"."uid"())::"text" = ("seller_id")::"text")));



CREATE POLICY "Profiles are viewable by everyone." ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Public can view background media" ON "public"."profile_background_media" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public pre-key read access" ON "public"."user_prekeys" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public profiles are viewable by everyone" ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Public profiles read" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public read active listings" ON "public"."market_listings" FOR SELECT USING ((("is_sold" = false) OR (("auth"."uid"())::"text" = ("user_id")::"text")));



CREATE POLICY "Public read active market listings" ON "public"."market_listings" FOR SELECT USING ((("status" = 'ACTIVE'::"text") AND ("expires_at" > "now"())));



CREATE POLICY "Public read approved publishers" ON "public"."store_publishers" FOR SELECT USING (true);



CREATE POLICY "Public read categories" ON "public"."market_categories" FOR SELECT USING (true);



CREATE POLICY "Public read feature_sync_plans" ON "public"."feature_sync_plans" FOR SELECT USING (("enabled" = true));



CREATE POLICY "Public read listing media" ON "public"."market_listing_media" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_listing_media"."listing_id") AND (("l"."status" = 'ACTIVE'::"text") OR ("l"."seller_id" = "auth"."uid"()))))));



CREATE POLICY "Public read market_sellers" ON "public"."market_sellers" FOR SELECT USING (true);



CREATE POLICY "Public read media assets" ON "public"."store_media_assets" FOR SELECT USING (true);



CREATE POLICY "Public read premium_products_config" ON "public"."premium_products_config" FOR SELECT USING (("enabled" = true));



CREATE POLICY "Public read published extensions" ON "public"."store_extensions" FOR SELECT USING (true);



CREATE POLICY "Public read published releases" ON "public"."store_releases" FOR SELECT USING (true);



CREATE POLICY "Public read ratings" ON "public"."store_ratings" FOR SELECT USING (true);



CREATE POLICY "Publishers insert own extensions" ON "public"."store_extensions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."store_publishers" "p"
  WHERE (("p"."id" = "store_extensions"."publisher_id") AND ("p"."user_id" = "auth"."uid"())))));



CREATE POLICY "Publishers manage own account" ON "public"."store_publishers" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Publishers update own draft extensions" ON "public"."store_extensions" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."store_publishers" "p"
  WHERE (("p"."id" = "store_extensions"."publisher_id") AND ("p"."user_id" = "auth"."uid"())))));



CREATE POLICY "Publishers view own submissions" ON "public"."store_submissions" USING ((EXISTS ( SELECT 1
   FROM "public"."store_publishers" "p"
  WHERE (("p"."id" = "store_submissions"."publisher_id") AND ("p"."user_id" = "auth"."uid"())))));



CREATE POLICY "Receivers can update invitation status" ON "public"."calendar_invitations" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "to_user_id")) WITH CHECK (("auth"."uid"() = "to_user_id"));



CREATE POLICY "Recipients can update metadata for referenced files" ON "public"."files" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM (("public"."message_attachment" "ma"
     JOIN "public"."messages" "m" ON ((("ma"."message_id")::"text" = ("m"."id")::"text")))
     JOIN "public"."chat_members" "cm" ON ((("m"."chat_id")::"text" = ("cm"."chat_id")::"text")))
  WHERE ((("ma"."file_id")::"text" = ("files"."id")::"text") AND (("cm"."user_id")::"text" = ("auth"."uid"())::"text"))))) WITH CHECK (true);



CREATE POLICY "Recipients can view referenced files" ON "public"."files" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (("public"."message_attachment" "ma"
     JOIN "public"."messages" "m" ON ((("ma"."message_id")::"text" = ("m"."id")::"text")))
     JOIN "public"."chat_members" "cm" ON ((("m"."chat_id")::"text" = ("cm"."chat_id")::"text")))
  WHERE ((("ma"."file_id")::"text" = ("files"."id")::"text") AND (("cm"."user_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Recipients can view their own imports" ON "public"."vault_share_imports" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "recipient_id"));



CREATE POLICY "Sellers delete listing media" ON "public"."market_listing_media" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_listing_media"."listing_id") AND ("l"."seller_id" = "auth"."uid"())))));



CREATE POLICY "Sellers delete own listing" ON "public"."market_listings" FOR DELETE USING (("auth"."uid"() = "seller_id"));



CREATE POLICY "Sellers insert listing media" ON "public"."market_listing_media" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_listing_media"."listing_id") AND ("l"."seller_id" = "auth"."uid"())))));



CREATE POLICY "Sellers update own listing" ON "public"."market_listings" FOR UPDATE USING (("auth"."uid"() = "seller_id"));



CREATE POLICY "Sellers view own listings" ON "public"."market_listings" FOR SELECT USING (("auth"."uid"() = "seller_id"));



CREATE POLICY "Senders can view imports of their shares" ON "public"."vault_share_imports" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vault_share_invites"
  WHERE (("vault_share_invites"."id" = "vault_share_imports"."share_id") AND ("vault_share_invites"."sender_id" = "auth"."uid"())))));



CREATE POLICY "Service role can insert security events" ON "public"."security_events" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can block others" ON "public"."blocked_users" FOR INSERT WITH CHECK (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can create reports" ON "public"."market_reports" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("reporter_id")::"text"));



CREATE POLICY "Users can create reports" ON "public"."reports" FOR INSERT WITH CHECK (("auth"."uid"() = "reporter_id"));



CREATE POLICY "Users can create their own chats" ON "public"."chats" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Users can delete own contacts" ON "public"."contacts" FOR DELETE USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can delete own listings" ON "public"."market_listings" FOR DELETE USING ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can delete own settings" ON "public"."user_settings" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their settings" ON "public"."user_settings" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert attachments for their messages" ON "public"."message_attachment" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."messages" "m"
  WHERE ((("m"."id")::"text" = ("message_attachment"."message_id")::"text") AND (("m"."sender_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Users can insert keys for chats they are in" ON "public"."conversation_keys" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = "conversation_keys"."conversation_id") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));



CREATE POLICY "Users can insert message requests as sender" ON "public"."message_requests" FOR INSERT TO "authenticated" WITH CHECK (("sender_id" = "auth"."uid"()));



CREATE POLICY "Users can insert messages into their chats" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_chat_member"("chat_id") AND ((("auth"."uid"())::"text" = ("sender_id")::"text") OR (("sender_id")::"text" = 'ai'::"text"))));



CREATE POLICY "Users can insert own contacts" ON "public"."contacts" FOR INSERT WITH CHECK (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can insert own listings" ON "public"."market_listings" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can insert own market_seller" ON "public"."market_sellers" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("id")::"text"));



CREATE POLICY "Users can insert own privacy settings" ON "public"."user_privacy_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert own profile" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."uid"())::"text" = ("id")::"text"));



CREATE POLICY "Users can insert own settings" ON "public"."user_settings" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert own usage sessions" ON "public"."usage_sessions" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own chat settings" ON "public"."user_chat_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own customization" ON "public"."user_app_customization" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own data exports" ON "public"."data_exports" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can insert their own privacy settings" ON "public"."user_privacy_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can insert their own reports" ON "public"."bug_reports" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own security settings" ON "public"."user_security_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their settings" ON "public"."user_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can join chats" ON "public"."chat_members" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can leave groups" ON "public"."chat_members" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage own bundle" ON "public"."user_bundles" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage own pre-keys" ON "public"."user_prekeys" TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage own vault folders" ON "public"."vault_folders" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their background media" ON "public"."profile_background_media" TO "authenticated" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can manage their blocked list" ON "public"."blocked_users" USING (("auth"."uid"() = "blocker_id")) WITH CHECK (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can manage their own TOTP accounts" ON "public"."secret_totp_accounts" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own XP" ON "public"."user_reading_xp" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own agenda attachments" ON "public"."agenda_attachment" USING ((EXISTS ( SELECT 1
   FROM "public"."calendar_items"
  WHERE (("calendar_items"."id" = "agenda_attachment"."agenda_event_id") AND ("calendar_items"."owner_id" = "auth"."uid"())))));



CREATE POLICY "Users can manage their own ai_chat_settings" ON "public"."ai_chat_settings" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own ai_credentials" ON "public"."ai_credentials" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own ai_memories" ON "public"."ai_memories" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own ai_provider_configs" ON "public"."ai_provider_configs" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own app customization" ON "public"."user_app_customization" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own backup codes" ON "public"."secret_backup_codes" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own blocks" ON "public"."blocked_users" USING (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can manage their own book achievements" ON "public"."book_achievements" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own book progress" ON "public"."book_progress" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own bookmarks" ON "public"."book_bookmarks" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own bookmarks" ON "public"."browser_bookmarks" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own books" ON "public"."books" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own browser bookmarks" ON "public"."browser_bookmarks" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own browser history" ON "public"."browser_history" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own call logs" ON "public"."call_logs" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own collection refs" ON "public"."book_collection_ref" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own collections" ON "public"."book_collections" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own contacts" ON "public"."contacts" TO "authenticated" USING (("auth"."uid"() = "owner_id")) WITH CHECK (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can manage their own containers" ON "public"."chat_containers" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can manage their own conversation keys" ON "public"."conversation_keys" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own customization" ON "public"."user_app_customization" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own deletion request" ON "public"."account_deletions" TO "authenticated" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can manage their own files" ON "public"."files" USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can manage their own folders" ON "public"."vault_folders" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own history" ON "public"."browser_history" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own items" ON "public"."calendar_items" USING (("auth"."uid"() = "owner_id")) WITH CHECK (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can manage their own message attachments" ON "public"."message_attachment" USING ((EXISTS ( SELECT 1
   FROM "public"."messages"
  WHERE (("messages"."id" = "message_attachment"."message_id") AND ("messages"."sender_id" = "auth"."uid"())))));



CREATE POLICY "Users can manage their own message visibility" ON "public"."message_visibility" TO "authenticated" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can manage their own note attachments" ON "public"."note_attachment" USING ((EXISTS ( SELECT 1
   FROM "public"."notes"
  WHERE (("notes"."id" = "note_attachment"."note_id") AND ("notes"."owner_id" = "auth"."uid"())))));



CREATE POLICY "Users can manage their own notifications" ON "public"."notifications" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can manage their own password history" ON "public"."secret_password_history" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own quotes" ON "public"."book_quotes" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own reading sessions" ON "public"."reading_sessions" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own reading stats" ON "public"."reading_stats" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own relationships" ON "public"."relationships" USING ((("user_id")::"text" = ("auth"."uid"())::"text"));



CREATE POLICY "Users can manage their own secret credentials" ON "public"."secret_credentials" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own secret settings" ON "public"."secret_settings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own security events" ON "public"."security_events" TO "authenticated" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can manage their own security settings" ON "public"."user_security_settings" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own sessions" ON "public"."user_sessions" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own settings" ON "public"."user_chat_settings" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own sms messages" ON "public"."sms_messages" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own sms threads" ON "public"."sms_threads" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own time tracking" ON "public"."user_time_tracking" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own todo lists" ON "public"."todo_lists" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own todo tasks" ON "public"."todo_tasks" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own vault items" ON "public"."secret_vault_items" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own vault items" ON "public"."vault_item" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own vault share invites" ON "public"."vault_share_invites" USING (("auth"."uid"() = "sender_id")) WITH CHECK (("auth"."uid"() = "sender_id"));



CREATE POLICY "Users can manage their own vault shares" ON "public"."vault_shares" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can manage their vault folders" ON "public"."vault_folders" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can manage their vault items" ON "public"."vault_item" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their vault items" ON "public"."vault_items" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can push notifications to others" ON "public"."notifications" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Users can read all privacy settings" ON "public"."user_privacy_settings" FOR SELECT USING (true);



CREATE POLICY "Users can read own admin status" ON "public"."admin_users" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can read own storage region" ON "public"."user_storage_regions" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can record a view" ON "public"."profile_views" FOR INSERT WITH CHECK (("auth"."uid"() = "viewer_id"));



CREATE POLICY "Users can record their own actions" ON "public"."official_broadcast_actions" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can record views" ON "public"."profile_views" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "viewer_id"));



CREATE POLICY "Users can remove saved market items" ON "public"."market_saved" FOR DELETE USING ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can report chats" ON "public"."chat_reports" FOR INSERT WITH CHECK ((("reporter_id")::"text" = ("auth"."uid"())::"text"));



CREATE POLICY "Users can save market items" ON "public"."market_saved" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can see their own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can see views on their own profile" ON "public"."profile_views" FOR SELECT USING ((("auth"."uid"() = "viewed_id") OR ("auth"."uid"() = "viewer_id")));



CREATE POLICY "Users can see who they blocked" ON "public"."blocked_users" FOR SELECT USING (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can see who viewed them" ON "public"."profile_views" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "viewed_id"));



CREATE POLICY "Users can select own usage sessions" ON "public"."usage_sessions" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can send invitations" ON "public"."calendar_invitations" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "from_user_id"));



CREATE POLICY "Users can unblock others" ON "public"."blocked_users" FOR DELETE USING (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can update own contacts" ON "public"."contacts" FOR UPDATE USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can update own listings" ON "public"."market_listings" FOR UPDATE USING ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can update own market_seller" ON "public"."market_sellers" FOR UPDATE USING ((("auth"."uid"())::"text" = ("id")::"text"));



CREATE POLICY "Users can update own preferences" ON "public"."billing_preferences" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own presence" ON "public"."user_presence" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own privacy settings" ON "public"."user_privacy_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING ((("auth"."uid"())::"text" = ("id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("id")::"text"));



CREATE POLICY "Users can update own settings" ON "public"."user_settings" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own usage sessions" ON "public"."usage_sessions" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update status of received messages" ON "public"."messages" FOR UPDATE USING (("auth"."uid"() <> "sender_id")) WITH CHECK (("status" = ANY (ARRAY['DELIVERED'::"text", 'SEEN'::"text"])));



CREATE POLICY "Users can update their message requests" ON "public"."message_requests" FOR UPDATE TO "authenticated" USING ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"()))) WITH CHECK ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"())));



CREATE POLICY "Users can update their own chat membership" ON "public"."chat_members" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own chat settings" ON "public"."user_chat_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own customization" ON "public"."user_app_customization" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own member settings" ON "public"."chat_members" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own messages" ON "public"."messages" FOR UPDATE TO "authenticated" USING (((("sender_id")::"text" = ("auth"."uid"())::"text") OR ((("sender_id")::"text" = 'ai'::"text") AND "public"."is_chat_member"("chat_id")))) WITH CHECK (((("sender_id")::"text" = ("auth"."uid"())::"text") OR ((("sender_id")::"text" = 'ai'::"text") AND "public"."is_chat_member"("chat_id"))));



CREATE POLICY "Users can update their own privacy settings" ON "public"."user_privacy_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "Users can update their own security settings" ON "public"."user_security_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their settings" ON "public"."user_settings" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK ((("auth"."uid"() = "user_id") AND ((("parental_controls" ->> 'supervisor_id'::"text") IS NULL) OR (("parental_controls" ->> 'supervisor_id'::"text") = ("auth"."uid"())::"text"))));



CREATE POLICY "Users can view active login challenges for themselves" ON "public"."two_factor_login_challenges" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view any bundle" ON "public"."user_bundles" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Users can view calls they are part of" ON "public"."call_sessions" FOR SELECT TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "Users can view invites shared with them" ON "public"."vault_share_invites" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vault_share_imports"
  WHERE (("vault_share_imports"."share_id" = "vault_share_invites"."id") AND ("vault_share_imports"."recipient_id" = "auth"."uid"())))));



CREATE POLICY "Users can view logs for their shares" ON "public"."vault_share_logs" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."vault_shares"
  WHERE (("vault_shares"."id" = "vault_share_logs"."share_id") AND ("vault_shares"."user_id" = ("auth"."uid"())::"text")))));



CREATE POLICY "Users can view messages in their chats" ON "public"."messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE (("chat_members"."chat_id" = "messages"."chat_id") AND ("chat_members"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can view own balance" ON "public"."billing_balances" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own contacts" ON "public"."contacts" FOR SELECT USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can view own entitlements" ON "public"."user_entitlements" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own invoices" ON "public"."billing_invoices" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own ledger" ON "public"."billing_ledger" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own payments" ON "public"."billing_payments" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own preferences" ON "public"."billing_preferences" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own redemption history" ON "public"."redeem_history" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own redemptions" ON "public"."subscription_key_redemptions" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own saved items" ON "public"."market_saved" FOR SELECT USING ((("auth"."uid"())::"text" = ("user_id")::"text"));



CREATE POLICY "Users can view own settings" ON "public"."user_settings" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own usage" ON "public"."billing_usage" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can view shared items" ON "public"."calendar_items" FOR SELECT TO "authenticated" USING (((("auth"."uid"())::"text" = ("owner_id")::"text") OR (EXISTS ( SELECT 1
   FROM "public"."calendar_invitations"
  WHERE ((("calendar_invitations"."from_user_id")::"text" = ("calendar_items"."owner_id")::"text") AND (("calendar_invitations"."to_user_id")::"text" = ("auth"."uid"())::"text") AND ("calendar_invitations"."status" = 'ACCEPTED'::"text"))))));



CREATE POLICY "Users can view their own 2fa factors" ON "public"."user_2fa_factors" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own chat settings" ON "public"."user_chat_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own controls" ON "public"."user_controls" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own customization" ON "public"."user_app_customization" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own data exports" ON "public"."data_exports" FOR SELECT TO "authenticated" USING ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can view their own items" ON "public"."calendar_items" FOR SELECT USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Users can view their own login attempts" ON "public"."login_attempts" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own message requests" ON "public"."message_requests" FOR SELECT TO "authenticated" USING ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"())));



CREATE POLICY "Users can view their own privacy settings" ON "public"."user_privacy_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own relationship scores" ON "public"."relationship_intelligence" FOR SELECT USING ((("auth"."uid"() = "user_a") OR ("auth"."uid"() = "user_b")));



CREATE POLICY "Users can view their own security events" ON "public"."security_events" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own security settings" ON "public"."user_security_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own sent/received invitations" ON "public"."calendar_invitations" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "from_user_id") OR ("auth"."uid"() = "to_user_id")));



CREATE POLICY "Users can view their own sessions" ON "public"."user_sessions" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users insert/update own ratings" ON "public"."store_ratings" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage checkins for own habits" ON "public"."habit_checkins" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_checkins"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_checkins"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid"))))));



CREATE POLICY "Users manage grace uses for own habits" ON "public"."habit_grace_uses" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_grace_uses"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_grace_uses"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid"))))));



CREATE POLICY "Users manage logs for own habits" ON "public"."habit_logs" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_logs"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_logs"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid"))))));



CREATE POLICY "Users manage own Keeftalk habits" ON "public"."habits" TO "authenticated" USING (("owner_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("owner_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "Users manage own devices" ON "public"."user_devices" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage own favorites" ON "public"."market_favorites" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage own habit milestones" ON "public"."habit_milestones" TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "Users manage own install requests" ON "public"."store_device_install_requests" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage schedules for own habits" ON "public"."habit_schedules" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_schedules"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_schedules"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid"))))));



CREATE POLICY "Users manage their own book settings" ON "public"."user_book_settings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own bookmarks" ON "public"."user_book_bookmarks" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own books" ON "public"."user_books" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own doc bookmarks" ON "public"."user_doc_bookmarks" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own doc highlights" ON "public"."user_doc_highlights" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own doc settings" ON "public"."user_doc_settings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own documents" ON "public"."user_docs" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own drawings" ON "public"."user_drawings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own highlights" ON "public"."user_book_highlights" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own page progress" ON "public"."user_book_progress" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their own sessions" ON "public"."user_book_sessions" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users read own entitlements" ON "public"."user_feature_entitlements" FOR SELECT USING ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users view involved offers" ON "public"."market_offers" FOR SELECT USING ((("auth"."uid"() = "buyer_id") OR (EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_offers"."listing_id") AND ("l"."seller_id" = "auth"."uid"()))))));



CREATE POLICY "Users view own installations" ON "public"."store_installations" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Vault users can view referenced files" ON "public"."files" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vault_items" "vi"
  WHERE (("vi"."file_id" = "files"."id") AND ("vi"."user_id" = ("auth"."uid"())::"text")))));



CREATE POLICY "View accessible files" ON "public"."files" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "owner_id") OR (EXISTS ( SELECT 1
   FROM ("public"."message_attachment" "ma"
     JOIN "public"."messages" "m" ON (("ma"."message_id" = "m"."id")))
  WHERE (("ma"."file_id" = "files"."id") AND (("m"."sender_id" = "auth"."uid"()) OR ("m"."chat_id" IN ( SELECT "chat_members"."chat_id"
           FROM "public"."chat_members"
          WHERE ("chat_members"."user_id" = "auth"."uid"()))))))) OR (EXISTS ( SELECT 1
   FROM ("public"."note_attachment" "na"
     JOIN "public"."notes" "n" ON (("na"."note_id" = "n"."id")))
  WHERE (("na"."file_id" = "files"."id") AND (("n"."owner_id" = "auth"."uid"()) OR ("n"."id" IN ( SELECT "note_shares"."note_id"
           FROM "public"."note_shares"
          WHERE ("note_shares"."user_id" = "auth"."uid"()))))))) OR (EXISTS ( SELECT 1
   FROM ("public"."agenda_attachment" "aa"
     JOIN "public"."calendar_items" "ci" ON (("aa"."agenda_event_id" = "ci"."id")))
  WHERE (("aa"."file_id" = "files"."id") AND ("ci"."owner_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."vault_item" "vi"
  WHERE (("vi"."file_id" = "files"."id") AND ("vi"."user_id" = "auth"."uid"()))))));



ALTER TABLE "public"."account_deletions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."admin_users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."agenda_attachment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ai_chat_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ai_credentials" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ai_memories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ai_provider_configs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."app_config" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_audit_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_balances" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_invoices" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_ledger" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_preferences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_pricing" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."billing_usage" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."blocked_users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_achievements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_bookmarks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_collection_ref" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_collections" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_quotes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."books" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."broadcasts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."browser_bookmarks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."browser_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bug_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."calendar_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."calendar_invitations" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "calendar_invitations_access" ON "public"."calendar_invitations" USING ((("from_user_id" = "auth"."uid"()) OR ("to_user_id" = "auth"."uid"())));



ALTER TABLE "public"."calendar_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."call_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."call_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."call_signaling" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."caller_contributions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."caller_id_config" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."caller_id_quotas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."caller_identities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."caller_nicknames" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."caller_spam_reporters" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "calls visible to participants" ON "public"."call_sessions" FOR SELECT USING ((("auth"."uid"() = "caller_id") OR ("auth"."uid"() = "receiver_id")));



CREATE POLICY "chat members can update chats" ON "public"."chats" FOR UPDATE USING ("public"."is_chat_member"("id"));



ALTER TABLE "public"."chat_containers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_members" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_members_insert" ON "public"."chat_members" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."chat_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chats" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chats_insert" ON "public"."chats" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "chats_select" ON "public"."chats" FOR SELECT TO "authenticated" USING ("public"."is_member_of"("id"));



CREATE POLICY "chats_update" ON "public"."chats" FOR UPDATE TO "authenticated" USING ("public"."is_admin_of"("id"));



ALTER TABLE "public"."contacts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."conversation_keys" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."data_exports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."families" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."family_groups" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."family_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."feature_sync_plans" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."files" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."habit_checkins" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."habit_grace_uses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."habit_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."habit_milestones" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."habit_schedules" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."habits" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."invitation_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_documents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."link_previews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."login_attempts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_chats" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_favorites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_listing_extensions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_listing_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_listings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_offers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_saved" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."market_sellers" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "members can read reactions" ON "public"."message_reactions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."messages" "m"
  WHERE (("m"."id" = "message_reactions"."message_id") AND "public"."is_chat_member"("m"."chat_id")))));



CREATE POLICY "members can see chat members" ON "public"."chat_members" FOR SELECT USING ("public"."is_chat_member"("chat_id"));



CREATE POLICY "members can update chats" ON "public"."chats" FOR UPDATE USING ("public"."is_chat_member"("id"));



CREATE POLICY "members can update message status" ON "public"."messages" FOR UPDATE USING ("public"."is_chat_member"("chat_id")) WITH CHECK ("public"."is_chat_member"("chat_id"));



CREATE POLICY "members insert messages" ON "public"."messages" FOR INSERT WITH CHECK ("public"."is_chat_member"("chat_id"));



CREATE POLICY "members update message status" ON "public"."messages" FOR UPDATE USING ("public"."is_chat_member"("chat_id")) WITH CHECK ("public"."is_chat_member"("chat_id"));



CREATE POLICY "members_admin" ON "public"."chat_members" TO "authenticated" USING ("public"."is_admin_of"("chat_id"));



CREATE POLICY "members_insert" ON "public"."chat_members" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "members_select" ON "public"."chat_members" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR "public"."is_member_of"("chat_id")));



ALTER TABLE "public"."message_attachment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."message_link_previews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."message_reactions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."message_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."message_visibility" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "messages_insert" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_member_of"("chat_id"));



CREATE POLICY "messages_select" ON "public"."messages" FOR SELECT TO "authenticated" USING ("public"."is_member_of"("chat_id"));



CREATE POLICY "messages_update" ON "public"."messages" FOR UPDATE USING (("sender_id" = "auth"."uid"()));



ALTER TABLE "public"."note_attachment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."note_shares" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notes_owner_all" ON "public"."notes" USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "notes_select_shared" ON "public"."notes" FOR SELECT TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "owner_id") OR ("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE ("note_shares"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))));



CREATE POLICY "notes_shared_select" ON "public"."notes" FOR SELECT USING (("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE ("note_shares"."user_id" = "auth"."uid"()))));



ALTER TABLE "public"."notes_sync_queue" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notes_update_shared" ON "public"."notes" FOR UPDATE TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "owner_id") OR ("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE (("note_shares"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("note_shares"."access" = 'write'::"text")))))) WITH CHECK (((( SELECT "auth"."uid"() AS "uid") = "owner_id") OR ("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE (("note_shares"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("note_shares"."access" = 'write'::"text"))))));



ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."official_broadcast_actions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "participants can insert signaling" ON "public"."call_signaling" FOR INSERT WITH CHECK ((("auth"."uid"() = "sender_id") AND (EXISTS ( SELECT 1
   FROM "public"."call_sessions"
  WHERE (("call_sessions"."id" = "call_signaling"."call_id") AND (("auth"."uid"() = "call_sessions"."caller_id") OR ("auth"."uid"() = "call_sessions"."receiver_id")))))));



CREATE POLICY "participants can update calls" ON "public"."call_sessions" FOR UPDATE USING ((("auth"."uid"() = "caller_id") OR ("auth"."uid"() = "receiver_id")));



ALTER TABLE "public"."pinned_messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."premium_products_config" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile_background_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile_views" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "reactions_insert" ON "public"."message_reactions" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "reactions_select" ON "public"."message_reactions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."messages"
  WHERE (("messages"."id" = "message_reactions"."message_id") AND "public"."is_member_of"("messages"."chat_id")))));



ALTER TABLE "public"."reading_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reading_stats" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."redeem_codes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."redeem_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."relationship_intelligence" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."relationships" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."secret_backup_codes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."secret_credentials" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."secret_password_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."secret_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."secret_totp_accounts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."secret_vault_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."security_events" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "shares_collaborator_select" ON "public"."note_shares" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "shares_owner_all" ON "public"."note_shares" USING ("public"."safe_check_note_owner"("note_id", "auth"."uid"()));



CREATE POLICY "signaling visible to participants" ON "public"."call_signaling" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."call_sessions"
  WHERE (("call_sessions"."id" = "call_signaling"."call_id") AND (("auth"."uid"() = "call_sessions"."caller_id") OR ("auth"."uid"() = "call_sessions"."receiver_id"))))));



ALTER TABLE "public"."sms_messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sms_threads" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."storage_lifecycle_queue" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_device_install_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_extensions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_installations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_media_assets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_publishers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_ratings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_releases" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_submissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscription_key_redemptions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscription_keys" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscription_metadata" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscriptions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."system_metrics" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."todo_lists" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."todo_tasks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."two_factor_login_challenges" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."two_factor_otp_challenges" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));



ALTER TABLE "public"."usage_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_2fa_backup_codes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_2fa_factors" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_app_customization" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_book_bookmarks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_book_highlights" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_book_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_book_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_book_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_books" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_broadcast_sync" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_bundles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_chat_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_controls" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_devices" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_doc_bookmarks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_doc_highlights" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_doc_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_docs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_drawings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_entitlements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_feature_entitlements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_prekeys" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_presence" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_privacy_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_reading_xp" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_recovery_seeds" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_security_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_storage_regions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_time_tracking" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users can create calls" ON "public"."call_sessions" FOR INSERT WITH CHECK (("auth"."uid"() = "caller_id"));



CREATE POLICY "users can insert own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "users can manage own reactions" ON "public"."message_reactions" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."vault_folders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_invite_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_item" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_share_imports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_share_invite_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_share_invites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_share_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vault_shares" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "verified members can read chats" ON "public"."chats" FOR SELECT USING (("public"."is_email_verified"() AND "public"."is_chat_member"("id")));



CREATE POLICY "verified members read messages" ON "public"."messages" FOR SELECT USING (("public"."is_email_verified"() AND "public"."is_chat_member"("chat_id")));



CREATE POLICY "verified users can read profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "security_private"."recovery_seeds" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_request_data_export"("p_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."can_request_data_export"("p_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_request_data_export"("p_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."check_can_message"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_can_message"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_can_message"("target_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_family_member_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_family_member_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_family_member_limit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_family_member_removal"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_family_member_removal"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_family_member_removal"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_file_upload_limits"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_file_upload_limits"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_file_upload_limits"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_membership"("p_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_membership"("p_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_membership"("p_chat_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_expired_entitlements"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_expired_entitlements"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_expired_entitlements"() TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") TO "service_role";



REVOKE ALL ON FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_expired_messages"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_expired_messages"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_expired_messages"() TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."enforce_name_change_cooldown"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_name_change_cooldown"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_name_change_cooldown"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_active_first_contact_policy"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_active_first_contact_policy"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_active_first_contact_policy"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_caller_id_pepper"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_caller_id_pepper"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_caller_id_pepper"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_caller_id_pepper"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_community_analytics"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_community_analytics"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_community_analytics"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_connection_paths"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_connection_paths"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_connection_paths"("target_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_chat_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_chat_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_chat_ids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_chats"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_chats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_chats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_official_chat"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_official_chat"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_official_chat"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_relationship_summary"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_relationship_summary"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_relationship_summary"("target_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_app_customization_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_app_customization_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_app_customization_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_heartbeat"("uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_heartbeat"("uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_heartbeat"("uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_message_sync_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_message_sync_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_message_sync_update"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_message"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_message_sync"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_message_sync"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_message_sync"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_profile_privacy"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_profile_privacy"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_profile_privacy"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_settings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_profile_phone_hmac"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_profile_phone_hmac"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_profile_phone_hmac"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_profile_view_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_profile_view_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_profile_view_notification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_security_event_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_security_event_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_security_event_notification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_team_member_upgrade"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_team_member_upgrade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_team_member_upgrade"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_visibility_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_visibility_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_visibility_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_import_progress"("import_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_import_progress"("import_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_import_progress"("import_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_profile_view_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_profile_view_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_profile_view_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_share_download"("share_token" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_share_download"("share_token" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_share_download"("share_token" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_story_like"("p_story_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_story_like"("p_story_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_story_like"("p_story_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_story_view"("p_story_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_story_view"("p_story_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_story_view"("p_story_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."initialize_user_customization"() TO "anon";
GRANT ALL ON FUNCTION "public"."initialize_user_customization"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."initialize_user_customization"() TO "service_role";



GRANT ALL ON FUNCTION "public"."internal_base32_decode"("p_base32" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."internal_base32_decode"("p_base32" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_base32_decode"("p_base32" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."internal_random_base32_secret"("p_length" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."internal_random_base32_secret"("p_length" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_random_base32_secret"("p_length" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_chat_member"("target_chat_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_chat_member"("target_chat_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_chat_member"("target_chat_id" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_email_verified"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_email_verified"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_email_verified"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_keeftalk_employee"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_keeftalk_employee"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_keeftalk_employee"("p_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_member_of"("p_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_member_of"("p_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_member_of"("p_chat_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) TO "service_role";



REVOKE ALL ON FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_new_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_new_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_new_message"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_security_event"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_security_event"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_security_event"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_session_revoked"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_session_revoked"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_session_revoked"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_message_update_relationship_strength"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_message_update_relationship_strength"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_message_update_relationship_strength"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_official_message_sent"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_official_message_sent"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_official_message_sent"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_vault_import_started"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_vault_import_started"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_vault_import_started"() TO "service_role";



GRANT ALL ON FUNCTION "public"."protect_parental_controls"() TO "anon";
GRANT ALL ON FUNCTION "public"."protect_parental_controls"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."protect_parental_controls"() TO "service_role";



GRANT ALL ON FUNCTION "public"."purge_expired_market_listings"() TO "anon";
GRANT ALL ON FUNCTION "public"."purge_expired_market_listings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."purge_expired_market_listings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."redeem_code"("p_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."redeem_code"("p_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."redeem_code"("p_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."reply_to_message_request"("p_request_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."reply_to_message_request"("p_request_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reply_to_message_request"("p_request_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_begin_totp_enrollment"() TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_begin_totp_enrollment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_begin_totp_enrollment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_generate_backup_codes"() TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_generate_backup_codes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_generate_backup_codes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_get_2fa_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_get_2fa_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_get_2fa_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_chat_last_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_chat_last_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_chat_last_message"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_chat_status_from_pointers"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_chat_status_from_pointers"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_chat_status_from_pointers"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_family_member_benefits"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_family_member_benefits"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_family_member_benefits"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_official_broadcasts"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_official_broadcasts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_official_broadcasts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_fcm_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_fcm_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_fcm_notification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_chat_last_activity"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_chat_last_activity"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_chat_last_activity"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_extension_install_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_extension_install_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_extension_install_stats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_extension_rating_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_extension_rating_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_extension_rating_stats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_file_reference_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_file_reference_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_file_reference_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_profile_storage_usage"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile_storage_usage"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile_storage_usage"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_active_benefits"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_active_benefits"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_active_benefits"() TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_typing_status"("payload" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_typing_status"("payload" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_typing_status"("payload" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_background_media"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_background_media"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_background_media"() TO "service_role";



GRANT ALL ON TABLE "public"."BIN_DB" TO "anon";
GRANT ALL ON TABLE "public"."BIN_DB" TO "authenticated";
GRANT ALL ON TABLE "public"."BIN_DB" TO "service_role";



GRANT ALL ON TABLE "public"."account_deletions" TO "anon";
GRANT ALL ON TABLE "public"."account_deletions" TO "authenticated";
GRANT ALL ON TABLE "public"."account_deletions" TO "service_role";



GRANT ALL ON TABLE "public"."admin_users" TO "anon";
GRANT ALL ON TABLE "public"."admin_users" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_users" TO "service_role";



GRANT ALL ON TABLE "public"."agenda_attachment" TO "anon";
GRANT ALL ON TABLE "public"."agenda_attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."agenda_attachment" TO "service_role";



GRANT ALL ON TABLE "public"."ai_chat_settings" TO "anon";
GRANT ALL ON TABLE "public"."ai_chat_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_chat_settings" TO "service_role";



GRANT ALL ON TABLE "public"."ai_credentials" TO "anon";
GRANT ALL ON TABLE "public"."ai_credentials" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_credentials" TO "service_role";



GRANT ALL ON TABLE "public"."ai_memories" TO "anon";
GRANT ALL ON TABLE "public"."ai_memories" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_memories" TO "service_role";



GRANT ALL ON TABLE "public"."ai_provider_configs" TO "anon";
GRANT ALL ON TABLE "public"."ai_provider_configs" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_provider_configs" TO "service_role";



GRANT ALL ON TABLE "public"."app_config" TO "anon";
GRANT ALL ON TABLE "public"."app_config" TO "authenticated";
GRANT ALL ON TABLE "public"."app_config" TO "service_role";



GRANT ALL ON TABLE "public"."billing_audit_log" TO "anon";
GRANT ALL ON TABLE "public"."billing_audit_log" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_audit_log" TO "service_role";



GRANT ALL ON TABLE "public"."billing_balances" TO "anon";
GRANT ALL ON TABLE "public"."billing_balances" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_balances" TO "service_role";



GRANT ALL ON TABLE "public"."billing_invoices" TO "anon";
GRANT ALL ON TABLE "public"."billing_invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_invoices" TO "service_role";



GRANT ALL ON TABLE "public"."billing_ledger" TO "anon";
GRANT ALL ON TABLE "public"."billing_ledger" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_ledger" TO "service_role";



GRANT ALL ON TABLE "public"."billing_payments" TO "anon";
GRANT ALL ON TABLE "public"."billing_payments" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_payments" TO "service_role";



GRANT ALL ON TABLE "public"."billing_preferences" TO "anon";
GRANT ALL ON TABLE "public"."billing_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_preferences" TO "service_role";



GRANT ALL ON TABLE "public"."billing_pricing" TO "anon";
GRANT ALL ON TABLE "public"."billing_pricing" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_pricing" TO "service_role";



GRANT ALL ON TABLE "public"."billing_usage" TO "anon";
GRANT ALL ON TABLE "public"."billing_usage" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_usage" TO "service_role";



GRANT ALL ON TABLE "public"."blocked_users" TO "anon";
GRANT ALL ON TABLE "public"."blocked_users" TO "authenticated";
GRANT ALL ON TABLE "public"."blocked_users" TO "service_role";



GRANT ALL ON TABLE "public"."book_achievements" TO "anon";
GRANT ALL ON TABLE "public"."book_achievements" TO "authenticated";
GRANT ALL ON TABLE "public"."book_achievements" TO "service_role";



GRANT ALL ON TABLE "public"."book_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."book_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."book_bookmarks" TO "service_role";



GRANT ALL ON TABLE "public"."book_collection_ref" TO "anon";
GRANT ALL ON TABLE "public"."book_collection_ref" TO "authenticated";
GRANT ALL ON TABLE "public"."book_collection_ref" TO "service_role";



GRANT ALL ON TABLE "public"."book_collections" TO "anon";
GRANT ALL ON TABLE "public"."book_collections" TO "authenticated";
GRANT ALL ON TABLE "public"."book_collections" TO "service_role";



GRANT ALL ON TABLE "public"."book_progress" TO "anon";
GRANT ALL ON TABLE "public"."book_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."book_progress" TO "service_role";



GRANT ALL ON TABLE "public"."book_quotes" TO "anon";
GRANT ALL ON TABLE "public"."book_quotes" TO "authenticated";
GRANT ALL ON TABLE "public"."book_quotes" TO "service_role";



GRANT ALL ON TABLE "public"."books" TO "anon";
GRANT ALL ON TABLE "public"."books" TO "authenticated";
GRANT ALL ON TABLE "public"."books" TO "service_role";



GRANT ALL ON TABLE "public"."broadcasts" TO "anon";
GRANT ALL ON TABLE "public"."broadcasts" TO "authenticated";
GRANT ALL ON TABLE "public"."broadcasts" TO "service_role";



GRANT ALL ON TABLE "public"."browser_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."browser_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."browser_bookmarks" TO "service_role";



GRANT ALL ON TABLE "public"."browser_history" TO "anon";
GRANT ALL ON TABLE "public"."browser_history" TO "authenticated";
GRANT ALL ON TABLE "public"."browser_history" TO "service_role";



GRANT ALL ON TABLE "public"."bug_reports" TO "anon";
GRANT ALL ON TABLE "public"."bug_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."bug_reports" TO "service_role";



GRANT ALL ON TABLE "public"."calendar_categories" TO "anon";
GRANT ALL ON TABLE "public"."calendar_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_categories" TO "service_role";



GRANT ALL ON TABLE "public"."calendar_invitations" TO "anon";
GRANT ALL ON TABLE "public"."calendar_invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_invitations" TO "service_role";



GRANT ALL ON TABLE "public"."calendar_items" TO "anon";
GRANT ALL ON TABLE "public"."calendar_items" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_items" TO "service_role";



GRANT ALL ON TABLE "public"."call_logs" TO "anon";
GRANT ALL ON TABLE "public"."call_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."call_logs" TO "service_role";



GRANT ALL ON TABLE "public"."call_sessions" TO "anon";
GRANT ALL ON TABLE "public"."call_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."call_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."call_signaling" TO "anon";
GRANT ALL ON TABLE "public"."call_signaling" TO "authenticated";
GRANT ALL ON TABLE "public"."call_signaling" TO "service_role";



GRANT ALL ON TABLE "public"."caller_contributions" TO "anon";
GRANT ALL ON TABLE "public"."caller_contributions" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_contributions" TO "service_role";



GRANT ALL ON TABLE "public"."caller_id_config" TO "anon";
GRANT ALL ON TABLE "public"."caller_id_config" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_id_config" TO "service_role";



GRANT ALL ON TABLE "public"."caller_id_quotas" TO "anon";
GRANT ALL ON TABLE "public"."caller_id_quotas" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_id_quotas" TO "service_role";



GRANT ALL ON TABLE "public"."caller_identities" TO "anon";
GRANT ALL ON TABLE "public"."caller_identities" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_identities" TO "service_role";



GRANT ALL ON TABLE "public"."caller_nicknames" TO "anon";
GRANT ALL ON TABLE "public"."caller_nicknames" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_nicknames" TO "service_role";



GRANT ALL ON TABLE "public"."caller_spam_reporters" TO "anon";
GRANT ALL ON TABLE "public"."caller_spam_reporters" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_spam_reporters" TO "service_role";



GRANT ALL ON TABLE "public"."chat_containers" TO "anon";
GRANT ALL ON TABLE "public"."chat_containers" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_containers" TO "service_role";



GRANT ALL ON TABLE "public"."chat_members" TO "anon";
GRANT ALL ON TABLE "public"."chat_members" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_members" TO "service_role";



GRANT ALL ON TABLE "public"."chats" TO "anon";
GRANT ALL ON TABLE "public"."chats" TO "authenticated";
GRANT ALL ON TABLE "public"."chats" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."chat_list_metadata" TO "anon";
GRANT ALL ON TABLE "public"."chat_list_metadata" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_list_metadata" TO "service_role";



GRANT ALL ON TABLE "public"."chat_reports" TO "anon";
GRANT ALL ON TABLE "public"."chat_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_reports" TO "service_role";



GRANT ALL ON TABLE "public"."community_growth_daily" TO "anon";
GRANT ALL ON TABLE "public"."community_growth_daily" TO "authenticated";
GRANT ALL ON TABLE "public"."community_growth_daily" TO "service_role";



GRANT ALL ON TABLE "public"."contacts" TO "anon";
GRANT ALL ON TABLE "public"."contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."contacts" TO "service_role";



GRANT ALL ON TABLE "public"."connections" TO "anon";
GRANT ALL ON TABLE "public"."connections" TO "authenticated";
GRANT ALL ON TABLE "public"."connections" TO "service_role";



GRANT ALL ON TABLE "public"."conversation_keys" TO "anon";
GRANT ALL ON TABLE "public"."conversation_keys" TO "authenticated";
GRANT ALL ON TABLE "public"."conversation_keys" TO "service_role";



GRANT ALL ON TABLE "public"."data_exports" TO "anon";
GRANT ALL ON TABLE "public"."data_exports" TO "authenticated";
GRANT ALL ON TABLE "public"."data_exports" TO "service_role";



GRANT ALL ON TABLE "public"."families" TO "anon";
GRANT ALL ON TABLE "public"."families" TO "authenticated";
GRANT ALL ON TABLE "public"."families" TO "service_role";



GRANT ALL ON TABLE "public"."family_groups" TO "anon";
GRANT ALL ON TABLE "public"."family_groups" TO "authenticated";
GRANT ALL ON TABLE "public"."family_groups" TO "service_role";



GRANT ALL ON TABLE "public"."family_permissions" TO "anon";
GRANT ALL ON TABLE "public"."family_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."family_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."feature_sync_plans" TO "anon";
GRANT ALL ON TABLE "public"."feature_sync_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."feature_sync_plans" TO "service_role";



GRANT ALL ON TABLE "public"."files" TO "anon";
GRANT ALL ON TABLE "public"."files" TO "authenticated";
GRANT ALL ON TABLE "public"."files" TO "service_role";



GRANT ALL ON TABLE "public"."habit_checkins" TO "anon";
GRANT ALL ON TABLE "public"."habit_checkins" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_checkins" TO "service_role";



GRANT ALL ON TABLE "public"."habit_grace_uses" TO "anon";
GRANT ALL ON TABLE "public"."habit_grace_uses" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_grace_uses" TO "service_role";



GRANT ALL ON TABLE "public"."habit_logs" TO "anon";
GRANT ALL ON TABLE "public"."habit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."habit_milestones" TO "anon";
GRANT ALL ON TABLE "public"."habit_milestones" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_milestones" TO "service_role";



GRANT ALL ON TABLE "public"."habit_schedules" TO "anon";
GRANT ALL ON TABLE "public"."habit_schedules" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_schedules" TO "service_role";



GRANT ALL ON TABLE "public"."habits" TO "anon";
GRANT ALL ON TABLE "public"."habits" TO "authenticated";
GRANT ALL ON TABLE "public"."habits" TO "service_role";



GRANT ALL ON TABLE "public"."invitation_permissions" TO "anon";
GRANT ALL ON TABLE "public"."invitation_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."invitation_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."legal_documents" TO "anon";
GRANT ALL ON TABLE "public"."legal_documents" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_documents" TO "service_role";



GRANT ALL ON TABLE "public"."link_previews" TO "anon";
GRANT ALL ON TABLE "public"."link_previews" TO "authenticated";
GRANT ALL ON TABLE "public"."link_previews" TO "service_role";



GRANT ALL ON TABLE "public"."login_attempts" TO "anon";
GRANT ALL ON TABLE "public"."login_attempts" TO "authenticated";
GRANT ALL ON TABLE "public"."login_attempts" TO "service_role";



GRANT ALL ON TABLE "public"."market_categories" TO "anon";
GRANT ALL ON TABLE "public"."market_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."market_categories" TO "service_role";



GRANT ALL ON TABLE "public"."market_chats" TO "anon";
GRANT ALL ON TABLE "public"."market_chats" TO "authenticated";
GRANT ALL ON TABLE "public"."market_chats" TO "service_role";



GRANT ALL ON TABLE "public"."market_favorites" TO "anon";
GRANT ALL ON TABLE "public"."market_favorites" TO "authenticated";
GRANT ALL ON TABLE "public"."market_favorites" TO "service_role";



GRANT ALL ON TABLE "public"."market_listing_extensions" TO "anon";
GRANT ALL ON TABLE "public"."market_listing_extensions" TO "authenticated";
GRANT ALL ON TABLE "public"."market_listing_extensions" TO "service_role";



GRANT ALL ON TABLE "public"."market_listing_media" TO "anon";
GRANT ALL ON TABLE "public"."market_listing_media" TO "authenticated";
GRANT ALL ON TABLE "public"."market_listing_media" TO "service_role";



GRANT ALL ON TABLE "public"."market_listings" TO "anon";
GRANT ALL ON TABLE "public"."market_listings" TO "authenticated";
GRANT ALL ON TABLE "public"."market_listings" TO "service_role";



GRANT ALL ON TABLE "public"."market_offers" TO "anon";
GRANT ALL ON TABLE "public"."market_offers" TO "authenticated";
GRANT ALL ON TABLE "public"."market_offers" TO "service_role";



GRANT ALL ON TABLE "public"."market_reports" TO "anon";
GRANT ALL ON TABLE "public"."market_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."market_reports" TO "service_role";



GRANT ALL ON TABLE "public"."market_saved" TO "anon";
GRANT ALL ON TABLE "public"."market_saved" TO "authenticated";
GRANT ALL ON TABLE "public"."market_saved" TO "service_role";



GRANT ALL ON TABLE "public"."market_sellers" TO "anon";
GRANT ALL ON TABLE "public"."market_sellers" TO "authenticated";
GRANT ALL ON TABLE "public"."market_sellers" TO "service_role";



GRANT ALL ON TABLE "public"."message_attachment" TO "anon";
GRANT ALL ON TABLE "public"."message_attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."message_attachment" TO "service_role";



GRANT ALL ON TABLE "public"."message_link_previews" TO "anon";
GRANT ALL ON TABLE "public"."message_link_previews" TO "authenticated";
GRANT ALL ON TABLE "public"."message_link_previews" TO "service_role";



GRANT ALL ON TABLE "public"."message_reactions" TO "anon";
GRANT ALL ON TABLE "public"."message_reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."message_reactions" TO "service_role";



GRANT ALL ON TABLE "public"."message_requests" TO "anon";
GRANT ALL ON TABLE "public"."message_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."message_requests" TO "service_role";



GRANT ALL ON TABLE "public"."message_visibility" TO "anon";
GRANT ALL ON TABLE "public"."message_visibility" TO "authenticated";
GRANT ALL ON TABLE "public"."message_visibility" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."note_attachment" TO "anon";
GRANT ALL ON TABLE "public"."note_attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."note_attachment" TO "service_role";



GRANT ALL ON TABLE "public"."note_shares" TO "anon";
GRANT ALL ON TABLE "public"."note_shares" TO "authenticated";
GRANT ALL ON TABLE "public"."note_shares" TO "service_role";



GRANT ALL ON TABLE "public"."notes" TO "anon";
GRANT ALL ON TABLE "public"."notes" TO "authenticated";
GRANT ALL ON TABLE "public"."notes" TO "service_role";



GRANT ALL ON TABLE "public"."notes_sync_queue" TO "anon";
GRANT ALL ON TABLE "public"."notes_sync_queue" TO "authenticated";
GRANT ALL ON TABLE "public"."notes_sync_queue" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."official_broadcast_actions" TO "anon";
GRANT ALL ON TABLE "public"."official_broadcast_actions" TO "authenticated";
GRANT ALL ON TABLE "public"."official_broadcast_actions" TO "service_role";



GRANT ALL ON TABLE "public"."pinned_messages" TO "anon";
GRANT ALL ON TABLE "public"."pinned_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."pinned_messages" TO "service_role";



GRANT ALL ON TABLE "public"."premium_products_config" TO "anon";
GRANT ALL ON TABLE "public"."premium_products_config" TO "authenticated";
GRANT ALL ON TABLE "public"."premium_products_config" TO "service_role";



GRANT ALL ON TABLE "public"."profile_background_media" TO "anon";
GRANT ALL ON TABLE "public"."profile_background_media" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_background_media" TO "service_role";



GRANT ALL ON TABLE "public"."profile_views" TO "anon";
GRANT ALL ON TABLE "public"."profile_views" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_views" TO "service_role";



GRANT ALL ON TABLE "public"."reading_sessions" TO "anon";
GRANT ALL ON TABLE "public"."reading_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."reading_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."reading_stats" TO "anon";
GRANT ALL ON TABLE "public"."reading_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."reading_stats" TO "service_role";



GRANT ALL ON TABLE "public"."redeem_codes" TO "anon";
GRANT ALL ON TABLE "public"."redeem_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."redeem_codes" TO "service_role";



GRANT ALL ON TABLE "public"."redeem_history" TO "anon";
GRANT ALL ON TABLE "public"."redeem_history" TO "authenticated";
GRANT ALL ON TABLE "public"."redeem_history" TO "service_role";



GRANT ALL ON TABLE "public"."relationship_intelligence" TO "anon";
GRANT ALL ON TABLE "public"."relationship_intelligence" TO "authenticated";
GRANT ALL ON TABLE "public"."relationship_intelligence" TO "service_role";



GRANT ALL ON TABLE "public"."relationships" TO "anon";
GRANT ALL ON TABLE "public"."relationships" TO "authenticated";
GRANT ALL ON TABLE "public"."relationships" TO "service_role";



GRANT ALL ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";



GRANT ALL ON TABLE "public"."secret_backup_codes" TO "anon";
GRANT ALL ON TABLE "public"."secret_backup_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_backup_codes" TO "service_role";



GRANT ALL ON TABLE "public"."secret_credentials" TO "anon";
GRANT ALL ON TABLE "public"."secret_credentials" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_credentials" TO "service_role";



GRANT ALL ON TABLE "public"."secret_password_history" TO "anon";
GRANT ALL ON TABLE "public"."secret_password_history" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_password_history" TO "service_role";



GRANT ALL ON TABLE "public"."secret_settings" TO "anon";
GRANT ALL ON TABLE "public"."secret_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_settings" TO "service_role";



GRANT ALL ON TABLE "public"."secret_totp_accounts" TO "anon";
GRANT ALL ON TABLE "public"."secret_totp_accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_totp_accounts" TO "service_role";



GRANT ALL ON TABLE "public"."secret_vault_items" TO "anon";
GRANT ALL ON TABLE "public"."secret_vault_items" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_vault_items" TO "service_role";



GRANT ALL ON TABLE "public"."security_events" TO "anon";
GRANT ALL ON TABLE "public"."security_events" TO "authenticated";
GRANT ALL ON TABLE "public"."security_events" TO "service_role";



GRANT ALL ON TABLE "public"."sms_messages" TO "anon";
GRANT ALL ON TABLE "public"."sms_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."sms_messages" TO "service_role";



GRANT ALL ON TABLE "public"."sms_threads" TO "anon";
GRANT ALL ON TABLE "public"."sms_threads" TO "authenticated";
GRANT ALL ON TABLE "public"."sms_threads" TO "service_role";



GRANT ALL ON TABLE "public"."storage_lifecycle_queue" TO "anon";
GRANT ALL ON TABLE "public"."storage_lifecycle_queue" TO "authenticated";
GRANT ALL ON TABLE "public"."storage_lifecycle_queue" TO "service_role";



GRANT ALL ON TABLE "public"."store_device_install_requests" TO "anon";
GRANT ALL ON TABLE "public"."store_device_install_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."store_device_install_requests" TO "service_role";



GRANT ALL ON TABLE "public"."store_extensions" TO "anon";
GRANT ALL ON TABLE "public"."store_extensions" TO "authenticated";
GRANT ALL ON TABLE "public"."store_extensions" TO "service_role";



GRANT ALL ON TABLE "public"."store_installations" TO "anon";
GRANT ALL ON TABLE "public"."store_installations" TO "authenticated";
GRANT ALL ON TABLE "public"."store_installations" TO "service_role";



GRANT ALL ON TABLE "public"."store_media_assets" TO "anon";
GRANT ALL ON TABLE "public"."store_media_assets" TO "authenticated";
GRANT ALL ON TABLE "public"."store_media_assets" TO "service_role";



GRANT ALL ON TABLE "public"."store_publishers" TO "anon";
GRANT ALL ON TABLE "public"."store_publishers" TO "authenticated";
GRANT ALL ON TABLE "public"."store_publishers" TO "service_role";



GRANT ALL ON TABLE "public"."store_ratings" TO "anon";
GRANT ALL ON TABLE "public"."store_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."store_ratings" TO "service_role";



GRANT ALL ON TABLE "public"."store_releases" TO "anon";
GRANT ALL ON TABLE "public"."store_releases" TO "authenticated";
GRANT ALL ON TABLE "public"."store_releases" TO "service_role";



GRANT ALL ON TABLE "public"."store_submissions" TO "anon";
GRANT ALL ON TABLE "public"."store_submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."store_submissions" TO "service_role";



GRANT ALL ON TABLE "public"."subscription_key_redemptions" TO "anon";
GRANT ALL ON TABLE "public"."subscription_key_redemptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_key_redemptions" TO "service_role";



GRANT ALL ON TABLE "public"."subscription_keys" TO "anon";
GRANT ALL ON TABLE "public"."subscription_keys" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_keys" TO "service_role";



GRANT ALL ON TABLE "public"."subscription_metadata" TO "anon";
GRANT ALL ON TABLE "public"."subscription_metadata" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_metadata" TO "service_role";



GRANT ALL ON TABLE "public"."subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscriptions" TO "service_role";



GRANT ALL ON TABLE "public"."system_metrics" TO "anon";
GRANT ALL ON TABLE "public"."system_metrics" TO "authenticated";
GRANT ALL ON TABLE "public"."system_metrics" TO "service_role";



GRANT ALL ON SEQUENCE "public"."system_metrics_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."system_metrics_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."system_metrics_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."todo_lists" TO "anon";
GRANT ALL ON TABLE "public"."todo_lists" TO "authenticated";
GRANT ALL ON TABLE "public"."todo_lists" TO "service_role";



GRANT ALL ON TABLE "public"."todo_tasks" TO "anon";
GRANT ALL ON TABLE "public"."todo_tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."todo_tasks" TO "service_role";



GRANT ALL ON TABLE "public"."two_factor_login_challenges" TO "anon";
GRANT ALL ON TABLE "public"."two_factor_login_challenges" TO "authenticated";
GRANT ALL ON TABLE "public"."two_factor_login_challenges" TO "service_role";



GRANT ALL ON TABLE "public"."two_factor_otp_challenges" TO "anon";
GRANT ALL ON TABLE "public"."two_factor_otp_challenges" TO "authenticated";
GRANT ALL ON TABLE "public"."two_factor_otp_challenges" TO "service_role";



GRANT ALL ON TABLE "public"."usage_sessions" TO "anon";
GRANT ALL ON TABLE "public"."usage_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."usage_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."user_2fa_backup_codes" TO "anon";
GRANT ALL ON TABLE "public"."user_2fa_backup_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."user_2fa_backup_codes" TO "service_role";



GRANT ALL ON TABLE "public"."user_2fa_factors" TO "anon";
GRANT ALL ON TABLE "public"."user_2fa_factors" TO "authenticated";
GRANT ALL ON TABLE "public"."user_2fa_factors" TO "service_role";



GRANT ALL ON TABLE "public"."user_app_customization" TO "anon";
GRANT ALL ON TABLE "public"."user_app_customization" TO "authenticated";
GRANT ALL ON TABLE "public"."user_app_customization" TO "service_role";



GRANT ALL ON TABLE "public"."user_book_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."user_book_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_bookmarks" TO "service_role";



GRANT ALL ON TABLE "public"."user_book_highlights" TO "anon";
GRANT ALL ON TABLE "public"."user_book_highlights" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_highlights" TO "service_role";



GRANT ALL ON TABLE "public"."user_book_progress" TO "anon";
GRANT ALL ON TABLE "public"."user_book_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_progress" TO "service_role";



GRANT ALL ON TABLE "public"."user_book_sessions" TO "anon";
GRANT ALL ON TABLE "public"."user_book_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."user_book_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_book_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_settings" TO "service_role";



GRANT ALL ON TABLE "public"."user_books" TO "anon";
GRANT ALL ON TABLE "public"."user_books" TO "authenticated";
GRANT ALL ON TABLE "public"."user_books" TO "service_role";



GRANT ALL ON TABLE "public"."user_broadcast_sync" TO "anon";
GRANT ALL ON TABLE "public"."user_broadcast_sync" TO "authenticated";
GRANT ALL ON TABLE "public"."user_broadcast_sync" TO "service_role";



GRANT ALL ON TABLE "public"."user_bundles" TO "anon";
GRANT ALL ON TABLE "public"."user_bundles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_bundles" TO "service_role";



GRANT ALL ON TABLE "public"."user_chat_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_chat_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_chat_settings" TO "service_role";



GRANT ALL ON TABLE "public"."user_controls" TO "anon";
GRANT ALL ON TABLE "public"."user_controls" TO "authenticated";
GRANT ALL ON TABLE "public"."user_controls" TO "service_role";



GRANT ALL ON TABLE "public"."user_devices" TO "anon";
GRANT ALL ON TABLE "public"."user_devices" TO "authenticated";
GRANT ALL ON TABLE "public"."user_devices" TO "service_role";



GRANT ALL ON TABLE "public"."user_doc_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."user_doc_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."user_doc_bookmarks" TO "service_role";



GRANT ALL ON TABLE "public"."user_doc_highlights" TO "anon";
GRANT ALL ON TABLE "public"."user_doc_highlights" TO "authenticated";
GRANT ALL ON TABLE "public"."user_doc_highlights" TO "service_role";



GRANT ALL ON TABLE "public"."user_doc_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_doc_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_doc_settings" TO "service_role";



GRANT ALL ON TABLE "public"."user_docs" TO "anon";
GRANT ALL ON TABLE "public"."user_docs" TO "authenticated";
GRANT ALL ON TABLE "public"."user_docs" TO "service_role";



GRANT ALL ON TABLE "public"."user_drawings" TO "anon";
GRANT ALL ON TABLE "public"."user_drawings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_drawings" TO "service_role";



GRANT ALL ON TABLE "public"."user_entitlements" TO "anon";
GRANT ALL ON TABLE "public"."user_entitlements" TO "authenticated";
GRANT ALL ON TABLE "public"."user_entitlements" TO "service_role";



GRANT ALL ON TABLE "public"."user_feature_entitlements" TO "anon";
GRANT ALL ON TABLE "public"."user_feature_entitlements" TO "authenticated";
GRANT ALL ON TABLE "public"."user_feature_entitlements" TO "service_role";



GRANT ALL ON TABLE "public"."user_prekeys" TO "anon";
GRANT ALL ON TABLE "public"."user_prekeys" TO "authenticated";
GRANT ALL ON TABLE "public"."user_prekeys" TO "service_role";



GRANT ALL ON TABLE "public"."user_presence" TO "anon";
GRANT ALL ON TABLE "public"."user_presence" TO "authenticated";
GRANT ALL ON TABLE "public"."user_presence" TO "service_role";



GRANT ALL ON TABLE "public"."user_privacy_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_privacy_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_privacy_settings" TO "service_role";



GRANT ALL ON TABLE "public"."user_reading_xp" TO "anon";
GRANT ALL ON TABLE "public"."user_reading_xp" TO "authenticated";
GRANT ALL ON TABLE "public"."user_reading_xp" TO "service_role";



GRANT ALL ON TABLE "public"."user_recovery_seeds" TO "service_role";



GRANT ALL ON TABLE "public"."user_security_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_security_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_security_settings" TO "service_role";



GRANT ALL ON TABLE "public"."user_sessions" TO "anon";
GRANT ALL ON TABLE "public"."user_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."user_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_settings" TO "service_role";



GRANT ALL ON TABLE "public"."user_storage_regions" TO "anon";
GRANT ALL ON TABLE "public"."user_storage_regions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_storage_regions" TO "service_role";



GRANT ALL ON TABLE "public"."user_time_tracking" TO "anon";
GRANT ALL ON TABLE "public"."user_time_tracking" TO "authenticated";
GRANT ALL ON TABLE "public"."user_time_tracking" TO "service_role";



GRANT ALL ON TABLE "public"."vault_folders" TO "anon";
GRANT ALL ON TABLE "public"."vault_folders" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_folders" TO "service_role";



GRANT ALL ON TABLE "public"."vault_invite_logs" TO "anon";
GRANT ALL ON TABLE "public"."vault_invite_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_invite_logs" TO "service_role";



GRANT ALL ON TABLE "public"."vault_item" TO "anon";
GRANT ALL ON TABLE "public"."vault_item" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_item" TO "service_role";



GRANT ALL ON TABLE "public"."vault_items" TO "anon";
GRANT ALL ON TABLE "public"."vault_items" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_items" TO "service_role";



GRANT ALL ON TABLE "public"."vault_share_imports" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_imports" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_imports" TO "service_role";



GRANT ALL ON TABLE "public"."vault_share_invite_items" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_invite_items" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_invite_items" TO "service_role";



GRANT ALL ON TABLE "public"."vault_share_invites" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_invites" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_invites" TO "service_role";



GRANT ALL ON TABLE "public"."vault_share_logs" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_logs" TO "service_role";



GRANT ALL ON TABLE "public"."vault_shares" TO "anon";
GRANT ALL ON TABLE "public"."vault_shares" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_shares" TO "service_role";



GRANT ALL ON TABLE "security_private"."recovery_seeds" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







