-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_chats market_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_pkey" PRIMARY KEY ("id");


--

-- Name: idx_market_chats_buyer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_chats_buyer_id" ON "public"."market_chats" USING "btree" ("buyer_id");


--

-- Name: idx_market_chats_listing_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_chats_listing_id" ON "public"."market_chats" USING "btree" ("listing_id");


--

-- Name: idx_market_chats_seller_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_chats_seller_id" ON "public"."market_chats" USING "btree" ("seller_id");


--

-- Name: market_chats market_chats_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: market_chats market_chats_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."market_listings"("id") ON DELETE CASCADE;


--

-- Name: market_chats market_chats_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_chats"
    ADD CONSTRAINT "market_chats_seller_id_fkey" FOREIGN KEY ("seller_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
