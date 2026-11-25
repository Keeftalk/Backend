-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notifications Users can manage their own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own notifications" ON "public"."notifications" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));


--

-- Name: notifications Users can push notifications to others; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can push notifications to others" ON "public"."notifications" FOR INSERT TO "authenticated" WITH CHECK (true);


--

-- Name: notifications Users can see their own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can see their own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

--
