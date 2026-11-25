-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_requests Users can insert message requests as sender; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert message requests as sender" ON "public"."message_requests" FOR INSERT TO "authenticated" WITH CHECK (("sender_id" = "auth"."uid"()));


--

-- Name: message_requests Users can update their message requests; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their message requests" ON "public"."message_requests" FOR UPDATE TO "authenticated" USING ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"()))) WITH CHECK ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"())));


--

-- Name: message_requests Users can view their own message requests; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own message requests" ON "public"."message_requests" FOR SELECT TO "authenticated" USING ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"())));


--

-- Name: message_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_requests" ENABLE ROW LEVEL SECURITY;

--
