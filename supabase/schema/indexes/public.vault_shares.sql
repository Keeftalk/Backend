-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_shares vault_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_shares"
    ADD CONSTRAINT "vault_shares_pkey" PRIMARY KEY ("id");


--

-- Name: vault_shares vault_shares_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_shares"
    ADD CONSTRAINT "vault_shares_token_key" UNIQUE ("token");


--

-- Name: idx_vault_shares_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_shares_item_id" ON "public"."vault_shares" USING "btree" ("item_id");


--

-- Name: idx_vault_shares_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_shares_token" ON "public"."vault_shares" USING "btree" ("token");


--

-- Name: idx_vault_shares_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_shares_user_id" ON "public"."vault_shares" USING "btree" ("user_id");


--

-- Name: vault_shares vault_shares_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_shares"
    ADD CONSTRAINT "vault_shares_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."vault_items"("id") ON DELETE CASCADE;


--
