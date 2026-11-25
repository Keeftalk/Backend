-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calculate_relationship_strength("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
