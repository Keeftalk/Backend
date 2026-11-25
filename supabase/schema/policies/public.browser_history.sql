-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: browser_history Users can manage their own browser history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own browser history" ON "public"."browser_history" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: browser_history Users can manage their own history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own history" ON "public"."browser_history" USING (("auth"."uid"() = "user_id"));


--

-- Name: browser_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."browser_history" ENABLE ROW LEVEL SECURITY;

--
