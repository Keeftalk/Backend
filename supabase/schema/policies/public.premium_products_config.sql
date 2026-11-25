-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: premium_products_config Public read premium_products_config; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read premium_products_config" ON "public"."premium_products_config" FOR SELECT USING (("enabled" = true));


--

-- Name: premium_products_config; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."premium_products_config" ENABLE ROW LEVEL SECURITY;

--
