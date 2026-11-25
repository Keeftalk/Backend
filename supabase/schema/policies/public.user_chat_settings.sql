-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_chat_settings Users can insert their own chat settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own chat settings" ON "public"."user_chat_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_chat_settings Users can manage their own settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own settings" ON "public"."user_chat_settings" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_chat_settings Users can update their own chat settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own chat settings" ON "public"."user_chat_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--

-- Name: user_chat_settings Users can view their own chat settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own chat settings" ON "public"."user_chat_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: user_chat_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_chat_settings" ENABLE ROW LEVEL SECURITY;

--
