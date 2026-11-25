-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_sessions Allow call creation by caller; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow call creation by caller" ON "public"."call_sessions" FOR INSERT TO "authenticated" WITH CHECK (("caller_id" = "auth"."uid"()));


--

-- Name: call_sessions Allow call read for participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow call read for participants" ON "public"."call_sessions" FOR SELECT TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));


--

-- Name: call_sessions Allow call updates for participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow call updates for participants" ON "public"."call_sessions" FOR UPDATE TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"()))) WITH CHECK ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));


--

-- Name: call_sessions Participants can update call state; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Participants can update call state" ON "public"."call_sessions" FOR UPDATE TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"()))) WITH CHECK ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));


--

-- Name: call_sessions Users can view calls they are part of; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view calls they are part of" ON "public"."call_sessions" FOR SELECT TO "authenticated" USING ((("caller_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));


--

-- Name: call_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."call_sessions" ENABLE ROW LEVEL SECURITY;

--

-- Name: call_sessions calls visible to participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "calls visible to participants" ON "public"."call_sessions" FOR SELECT USING ((("auth"."uid"() = "caller_id") OR ("auth"."uid"() = "receiver_id")));


--

-- Name: call_sessions participants can update calls; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "participants can update calls" ON "public"."call_sessions" FOR UPDATE USING ((("auth"."uid"() = "caller_id") OR ("auth"."uid"() = "receiver_id")));


--

-- Name: call_sessions users can create calls; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users can create calls" ON "public"."call_sessions" FOR INSERT WITH CHECK (("auth"."uid"() = "caller_id"));


--
