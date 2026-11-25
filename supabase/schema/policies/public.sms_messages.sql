-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sms_messages Users can manage their own sms messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own sms messages" ON "public"."sms_messages" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: sms_messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."sms_messages" ENABLE ROW LEVEL SECURITY;

--
