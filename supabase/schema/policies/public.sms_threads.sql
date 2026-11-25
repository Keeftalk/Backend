-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sms_threads Users can manage their own sms threads; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own sms threads" ON "public"."sms_threads" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: sms_threads; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."sms_threads" ENABLE ROW LEVEL SECURITY;

--
