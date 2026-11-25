-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_bundles Users can manage own bundle; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage own bundle" ON "public"."user_bundles" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_bundles Users can view any bundle; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view any bundle" ON "public"."user_bundles" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));


--

-- Name: user_bundles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_bundles" ENABLE ROW LEVEL SECURITY;

--
