-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: todo_tasks Users can manage their own todo tasks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own todo tasks" ON "public"."todo_tasks" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: todo_tasks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."todo_tasks" ENABLE ROW LEVEL SECURITY;

--
