-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: is_chat_participant("uuid", "uuid", "uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
