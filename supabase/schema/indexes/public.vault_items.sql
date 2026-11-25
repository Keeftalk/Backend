-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_items vault_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_items"
    ADD CONSTRAINT "vault_items_pkey" PRIMARY KEY ("id");


--

-- Name: idx_vault_items_folder_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_items_folder_id" ON "public"."vault_items" USING "btree" ("folder_id");


--

-- Name: vault_items vault_items_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_items"
    ADD CONSTRAINT "vault_items_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id") ON DELETE CASCADE;


--

-- Name: vault_items vault_items_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_items"
    ADD CONSTRAINT "vault_items_folder_id_fkey" FOREIGN KEY ("folder_id") REFERENCES "public"."vault_folders"("id") ON DELETE SET NULL;


--
