-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_sellers Public read market_sellers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read market_sellers" ON "public"."market_sellers" FOR SELECT USING (true);


--

-- Name: market_sellers Users can insert own market_seller; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own market_seller" ON "public"."market_sellers" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("id")::"text"));


--

-- Name: market_sellers Users can update own market_seller; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own market_seller" ON "public"."market_sellers" FOR UPDATE USING ((("auth"."uid"())::"text" = ("id")::"text"));


--

-- Name: market_sellers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_sellers" ENABLE ROW LEVEL SECURITY;

--
