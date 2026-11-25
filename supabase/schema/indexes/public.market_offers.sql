-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_offers market_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_offers"
    ADD CONSTRAINT "market_offers_pkey" PRIMARY KEY ("id");


--

-- Name: idx_market_offers_buyer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_offers_buyer" ON "public"."market_offers" USING "btree" ("buyer_id");


--

-- Name: idx_market_offers_listing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_offers_listing" ON "public"."market_offers" USING "btree" ("listing_id");


--

-- Name: market_offers market_offers_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_offers"
    ADD CONSTRAINT "market_offers_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: market_offers market_offers_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_offers"
    ADD CONSTRAINT "market_offers_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;


--
