-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listings market_listings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_pkey" PRIMARY KEY ("id");


--

-- Name: idx_market_listings_cat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_cat" ON "public"."market_listings" USING "btree" ("cat");


--

-- Name: idx_market_listings_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_category" ON "public"."market_listings" USING "btree" ("category_id", "subcategory");


--

-- Name: idx_market_listings_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_created" ON "public"."market_listings" USING "btree" ("created_at" DESC);


--

-- Name: idx_market_listings_exp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_exp" ON "public"."market_listings" USING "btree" ("exp");


--

-- Name: idx_market_listings_is_sold; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_is_sold" ON "public"."market_listings" USING "btree" ("is_sold");


--

-- Name: idx_market_listings_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_location" ON "public"."market_listings" USING "btree" ("latitude", "longitude");


--

-- Name: idx_market_listings_price; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_price" ON "public"."market_listings" USING "btree" ("price");


--

-- Name: idx_market_listings_seller; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_seller" ON "public"."market_listings" USING "btree" ("seller_id");


--

-- Name: idx_market_listings_status_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_status_expires" ON "public"."market_listings" USING "btree" ("status", "expires_at");


--

-- Name: idx_market_listings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_market_listings_user_id" ON "public"."market_listings" USING "btree" ("user_id");


--

-- Name: market_listings market_listings_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."market_categories"("id");


--

-- Name: market_listings market_listings_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_seller_id_fkey" FOREIGN KEY ("seller_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: market_listings market_listings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."market_listings"
    ADD CONSTRAINT "market_listings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
