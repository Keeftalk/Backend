-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: check_can_message("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
