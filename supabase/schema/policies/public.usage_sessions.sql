-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: usage_sessions Users can insert own usage sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own usage sessions" ON "public"."usage_sessions" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: usage_sessions Users can select own usage sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can select own usage sessions" ON "public"."usage_sessions" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: usage_sessions Users can update own usage sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own usage sessions" ON "public"."usage_sessions" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--

-- Name: usage_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."usage_sessions" ENABLE ROW LEVEL SECURITY;

--
