-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_folders vault_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_folders"
    ADD CONSTRAINT "vault_folders_pkey" PRIMARY KEY ("id");


--

-- Name: idx_vault_folders_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_folders_parent_id" ON "public"."vault_folders" USING "btree" ("parent_id");


--

-- Name: vault_folders vault_folders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_folders"
    ADD CONSTRAINT "vault_folders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
