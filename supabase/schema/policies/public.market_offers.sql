-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_offers Buyers create offer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Buyers create offer" ON "public"."market_offers" FOR INSERT WITH CHECK (("auth"."uid"() = "buyer_id"));


--

-- Name: market_offers Involved users update offer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Involved users update offer" ON "public"."market_offers" FOR UPDATE USING ((("auth"."uid"() = "buyer_id") OR (EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_offers"."listing_id") AND ("l"."seller_id" = "auth"."uid"()))))));


--

-- Name: market_offers Users view involved offers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users view involved offers" ON "public"."market_offers" FOR SELECT USING ((("auth"."uid"() = "buyer_id") OR (EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_offers"."listing_id") AND ("l"."seller_id" = "auth"."uid"()))))));


--

-- Name: market_offers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_offers" ENABLE ROW LEVEL SECURITY;

--
