-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_categories Authenticated users insert categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users insert categories" ON "public"."market_categories" FOR INSERT WITH CHECK (true);


--

-- Name: market_categories Public read categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read categories" ON "public"."market_categories" FOR SELECT USING (true);


--

-- Name: market_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_categories" ENABLE ROW LEVEL SECURITY;

--
