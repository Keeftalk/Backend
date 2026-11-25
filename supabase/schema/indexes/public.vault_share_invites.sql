-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_invites vault_share_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_invites"
    ADD CONSTRAINT "vault_share_invites_pkey" PRIMARY KEY ("id");


--

-- Name: vault_share_invites vault_share_invites_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_invites"
    ADD CONSTRAINT "vault_share_invites_token_hash_key" UNIQUE ("token_hash");


--

-- Name: idx_vault_share_invites_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_share_invites_sender_id" ON "public"."vault_share_invites" USING "btree" ("sender_id");


--

-- Name: idx_vault_share_invites_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_share_invites_token_hash" ON "public"."vault_share_invites" USING "btree" ("token_hash");


--

-- Name: vault_share_invites vault_share_invites_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_invites"
    ADD CONSTRAINT "vault_share_invites_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
