-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: app_config Anyone can read app_config; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can read app_config" ON "public"."app_config" FOR SELECT TO "anon", "authenticated" USING (true);


--

-- Name: app_config; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."app_config" ENABLE ROW LEVEL SECURITY;

--
