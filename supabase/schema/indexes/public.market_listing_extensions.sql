-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listing_extensions market_listing_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listing_extensions"
    ADD CONSTRAINT "market_listing_extensions_pkey" PRIMARY KEY ("id");


--

-- Name: idx_market_listing_extensions_listing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listing_extensions_listing" ON "public"."market_listing_extensions" USING "btree" ("listing_id");


--

-- Name: market_listing_extensions market_listing_extensions_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listing_extensions"
    ADD CONSTRAINT "market_listing_extensions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;


--
