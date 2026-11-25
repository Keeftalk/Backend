-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_sessions Users can manage their own sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own sessions" ON "public"."user_sessions" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_sessions Users can view their own sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own sessions" ON "public"."user_sessions" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_sessions" ENABLE ROW LEVEL SECURITY;

--
