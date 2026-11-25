-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_app_customization Users can insert their own customization; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own customization" ON "public"."user_app_customization" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_app_customization Users can manage their own app customization; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own app customization" ON "public"."user_app_customization" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_app_customization Users can manage their own customization; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own customization" ON "public"."user_app_customization" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_app_customization Users can update their own customization; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own customization" ON "public"."user_app_customization" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--

-- Name: user_app_customization Users can view their own customization; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own customization" ON "public"."user_app_customization" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: user_app_customization; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_app_customization" ENABLE ROW LEVEL SECURITY;

--
