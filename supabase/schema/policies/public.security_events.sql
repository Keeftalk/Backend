-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: security_events Service role can insert security events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Service role can insert security events" ON "public"."security_events" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: security_events Users can manage their own security events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own security events" ON "public"."security_events" TO "authenticated" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: security_events Users can view their own security events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own security events" ON "public"."security_events" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: security_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."security_events" ENABLE ROW LEVEL SECURITY;

--
