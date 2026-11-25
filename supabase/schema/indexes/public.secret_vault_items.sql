-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_vault_items secret_vault_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_vault_items"
    ADD CONSTRAINT "secret_vault_items_pkey" PRIMARY KEY ("id");


--

-- Name: idx_secret_vault_items_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_vault_items_type" ON "public"."secret_vault_items" USING "btree" ("item_type");


--

-- Name: idx_secret_vault_items_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_vault_items_user" ON "public"."secret_vault_items" USING "btree" ("user_id");


--

-- Name: secret_vault_items secret_vault_items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_vault_items"
    ADD CONSTRAINT "secret_vault_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
