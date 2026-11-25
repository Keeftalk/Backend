-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: blocked_users Users can block others; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can block others" ON "public"."blocked_users" FOR INSERT WITH CHECK (("auth"."uid"() = "blocker_id"));


--

-- Name: blocked_users Users can manage their blocked list; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their blocked list" ON "public"."blocked_users" USING (("auth"."uid"() = "blocker_id")) WITH CHECK (("auth"."uid"() = "blocker_id"));


--

-- Name: blocked_users Users can manage their own blocks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own blocks" ON "public"."blocked_users" USING (("auth"."uid"() = "blocker_id"));


--

-- Name: blocked_users Users can see who they blocked; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can see who they blocked" ON "public"."blocked_users" FOR SELECT USING (("auth"."uid"() = "blocker_id"));


--

-- Name: blocked_users Users can unblock others; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can unblock others" ON "public"."blocked_users" FOR DELETE USING (("auth"."uid"() = "blocker_id"));


--

-- Name: blocked_users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."blocked_users" ENABLE ROW LEVEL SECURITY;

--
