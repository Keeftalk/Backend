-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_chat_settings Users can manage their own ai_chat_settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own ai_chat_settings" ON "public"."ai_chat_settings" USING (("auth"."uid"() = "user_id"));


--

-- Name: ai_chat_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."ai_chat_settings" ENABLE ROW LEVEL SECURITY;

--
