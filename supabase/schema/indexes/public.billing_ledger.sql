-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_ledger billing_ledger_idempotency_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_idempotency_key_key" UNIQUE ("idempotency_key");


--

-- Name: billing_ledger billing_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_pkey" PRIMARY KEY ("id");


--

-- Name: idx_billing_ledger_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_billing_ledger_user" ON "public"."billing_ledger" USING "btree" ("user_id", "created_at");


--

-- Name: billing_ledger billing_ledger_pricing_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_pricing_version_id_fkey" FOREIGN KEY ("pricing_version_id") REFERENCES "public"."billing_pricing"("id");


--

-- Name: billing_ledger billing_ledger_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_ledger"
    ADD CONSTRAINT "billing_ledger_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
