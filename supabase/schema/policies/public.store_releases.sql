-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_releases Public read published releases; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read published releases" ON "public"."store_releases" FOR SELECT USING (true);


--

-- Name: store_releases; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_releases" ENABLE ROW LEVEL SECURITY;

--
