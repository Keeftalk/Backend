-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_signaling; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."call_signaling" ENABLE ROW LEVEL SECURITY;

--

-- Name: call_signaling participants can insert signaling; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "participants can insert signaling" ON "public"."call_signaling" FOR INSERT WITH CHECK ((("auth"."uid"() = "sender_id") AND (EXISTS ( SELECT 1
   FROM "public"."call_sessions"
  WHERE (("call_sessions"."id" = "call_signaling"."call_id") AND (("auth"."uid"() = "call_sessions"."caller_id") OR ("auth"."uid"() = "call_sessions"."receiver_id")))))));


--

-- Name: call_signaling signaling visible to participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "signaling visible to participants" ON "public"."call_signaling" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."call_sessions"
  WHERE (("call_sessions"."id" = "call_signaling"."call_id") AND (("auth"."uid"() = "call_sessions"."caller_id") OR ("auth"."uid"() = "call_sessions"."receiver_id"))))));


--
