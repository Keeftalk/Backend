-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: get_connection_paths("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
