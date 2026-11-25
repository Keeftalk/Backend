-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_imports vault_share_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_imports"
    ADD CONSTRAINT "vault_share_imports_pkey" PRIMARY KEY ("id");


--

-- Name: idx_vault_share_imports_recipient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_share_imports_recipient_id" ON "public"."vault_share_imports" USING "btree" ("recipient_id");


--

-- Name: idx_vault_share_imports_share_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_share_imports_share_id" ON "public"."vault_share_imports" USING "btree" ("share_id");


--

-- Name: vault_share_imports vault_share_imports_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_imports"
    ADD CONSTRAINT "vault_share_imports_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: vault_share_imports vault_share_imports_share_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_imports"
    ADD CONSTRAINT "vault_share_imports_share_id_fkey" FOREIGN KEY ("share_id") REFERENCES "public"."vault_share_invites"("id") ON DELETE CASCADE;


--
