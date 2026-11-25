-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_invite_logs vault_invite_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_invite_logs"
    ADD CONSTRAINT "vault_invite_logs_pkey" PRIMARY KEY ("id");


--

-- Name: idx_vault_invite_logs_invite_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_invite_logs_invite_id" ON "public"."vault_invite_logs" USING "btree" ("invite_id");


--

-- Name: vault_invite_logs vault_invite_logs_invite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_invite_logs"
    ADD CONSTRAINT "vault_invite_logs_invite_id_fkey" FOREIGN KEY ("invite_id") REFERENCES "public"."vault_share_invites"("id") ON DELETE CASCADE;


--
