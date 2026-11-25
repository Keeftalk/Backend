-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_relationship_summary("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
