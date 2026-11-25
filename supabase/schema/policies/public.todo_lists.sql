-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: todo_lists Users can manage their own todo lists; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own todo lists" ON "public"."todo_lists" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: todo_lists; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."todo_lists" ENABLE ROW LEVEL SECURITY;

--
