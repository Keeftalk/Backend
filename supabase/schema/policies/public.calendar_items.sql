-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calendar_items Users can manage their own items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own items" ON "public"."calendar_items" USING (("auth"."uid"() = "owner_id")) WITH CHECK (("auth"."uid"() = "owner_id"));


--

-- Name: calendar_items Users can view shared items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view shared items" ON "public"."calendar_items" FOR SELECT TO "authenticated" USING (((("auth"."uid"())::"text" = ("owner_id")::"text") OR (EXISTS ( SELECT 1
   FROM "public"."calendar_invitations"
  WHERE ((("calendar_invitations"."from_user_id")::"text" = ("calendar_items"."owner_id")::"text") AND (("calendar_invitations"."to_user_id")::"text" = ("auth"."uid"())::"text") AND ("calendar_invitations"."status" = 'ACCEPTED'::"text"))))));


--

-- Name: calendar_items Users can view their own items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own items" ON "public"."calendar_items" FOR SELECT USING (("auth"."uid"() = "owner_id"));


--

-- Name: calendar_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."calendar_items" ENABLE ROW LEVEL SECURITY;

--
