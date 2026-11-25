-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listings Authenticated users create listing; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users create listing" ON "public"."market_listings" FOR INSERT WITH CHECK (("auth"."uid"() = "seller_id"));


--

-- Name: market_listings Public read active listings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read active listings" ON "public"."market_listings" FOR SELECT USING ((("is_sold" = false) OR (("auth"."uid"())::"text" = ("user_id")::"text")));


--

-- Name: market_listings Public read active market listings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read active market listings" ON "public"."market_listings" FOR SELECT USING ((("status" = 'ACTIVE'::"text") AND ("expires_at" > "now"())));


--

-- Name: market_listings Sellers delete own listing; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sellers delete own listing" ON "public"."market_listings" FOR DELETE USING (("auth"."uid"() = "seller_id"));


--

-- Name: market_listings Sellers update own listing; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sellers update own listing" ON "public"."market_listings" FOR UPDATE USING (("auth"."uid"() = "seller_id"));


--

-- Name: market_listings Sellers view own listings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sellers view own listings" ON "public"."market_listings" FOR SELECT USING (("auth"."uid"() = "seller_id"));


--

-- Name: market_listings Users can delete own listings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete own listings" ON "public"."market_listings" FOR DELETE USING ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: market_listings Users can insert own listings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own listings" ON "public"."market_listings" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: market_listings Users can update own listings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own listings" ON "public"."market_listings" FOR UPDATE USING ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: market_listings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_listings" ENABLE ROW LEVEL SECURITY;

--
