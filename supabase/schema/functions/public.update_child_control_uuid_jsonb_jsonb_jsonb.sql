-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: update_child_control("uuid", "jsonb", "jsonb", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
