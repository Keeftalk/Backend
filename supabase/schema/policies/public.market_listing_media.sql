-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listing_media Public read listing media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read listing media" ON "public"."market_listing_media" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_listing_media"."listing_id") AND (("l"."status" = 'ACTIVE'::"text") OR ("l"."seller_id" = "auth"."uid"()))))));


--

-- Name: market_listing_media Sellers delete listing media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sellers delete listing media" ON "public"."market_listing_media" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_listing_media"."listing_id") AND ("l"."seller_id" = "auth"."uid"())))));


--

-- Name: market_listing_media Sellers insert listing media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sellers insert listing media" ON "public"."market_listing_media" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."market_listings" "l"
  WHERE (("l"."id" = "market_listing_media"."listing_id") AND ("l"."seller_id" = "auth"."uid"())))));


--

-- Name: market_listing_media; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_listing_media" ENABLE ROW LEVEL SECURITY;

--
