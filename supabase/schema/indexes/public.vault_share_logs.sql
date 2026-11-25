-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_logs vault_share_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_logs"
    ADD CONSTRAINT "vault_share_logs_pkey" PRIMARY KEY ("id");


--

-- Name: idx_vault_share_logs_share_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_vault_share_logs_share_time" ON "public"."vault_share_logs" USING "btree" ("share_id", "created_at");


--

-- Name: vault_share_logs vault_share_logs_share_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_share_logs"
    ADD CONSTRAINT "vault_share_logs_share_id_fkey" FOREIGN KEY ("share_id") REFERENCES "public"."vault_shares"("id") ON DELETE CASCADE;


--
