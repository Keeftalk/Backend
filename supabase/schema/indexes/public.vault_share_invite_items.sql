-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_invite_items vault_share_invite_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_invite_items"
    ADD CONSTRAINT "vault_share_invite_items_pkey" PRIMARY KEY ("id");


--

-- Name: idx_vault_share_invite_items_invite_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_share_invite_items_invite_id" ON "public"."vault_share_invite_items" USING "btree" ("invite_id");


--

-- Name: vault_share_invite_items vault_share_invite_items_invite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_invite_items"
    ADD CONSTRAINT "vault_share_invite_items_invite_id_fkey" FOREIGN KEY ("invite_id") REFERENCES "public"."vault_share_invites"("id") ON DELETE CASCADE;


--
