-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_media_assets Public read media assets; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read media assets" ON "public"."store_media_assets" FOR SELECT USING (true);


--

-- Name: store_media_assets; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_media_assets" ENABLE ROW LEVEL SECURITY;

--
