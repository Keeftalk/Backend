-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listing_media market_listing_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listing_media"
    ADD CONSTRAINT "market_listing_media_pkey" PRIMARY KEY ("id");


--

-- Name: idx_market_media_listing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_media_listing" ON "public"."market_listing_media" USING "btree" ("listing_id");


--

-- Name: market_listing_media market_listing_media_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listing_media"
    ADD CONSTRAINT "market_listing_media_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;


--
