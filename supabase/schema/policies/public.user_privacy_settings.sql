-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_privacy_settings Users can insert own privacy settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own privacy settings" ON "public"."user_privacy_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_privacy_settings Users can insert their own privacy settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own privacy settings" ON "public"."user_privacy_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_privacy_settings Users can read all privacy settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read all privacy settings" ON "public"."user_privacy_settings" FOR SELECT USING (true);


--

-- Name: user_privacy_settings Users can update own privacy settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own privacy settings" ON "public"."user_privacy_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--

-- Name: user_privacy_settings Users can update their own privacy settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own privacy settings" ON "public"."user_privacy_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--

-- Name: user_privacy_settings Users can view their own privacy settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own privacy settings" ON "public"."user_privacy_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: user_privacy_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_privacy_settings" ENABLE ROW LEVEL SECURITY;

--
