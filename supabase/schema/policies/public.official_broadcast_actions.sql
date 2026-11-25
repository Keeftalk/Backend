-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: official_broadcast_actions Official users can read analytics; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Official users can read analytics" ON "public"."official_broadcast_actions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_official" = true)))));


--

-- Name: official_broadcast_actions Users can record their own actions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can record their own actions" ON "public"."official_broadcast_actions" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: official_broadcast_actions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."official_broadcast_actions" ENABLE ROW LEVEL SECURITY;

--
