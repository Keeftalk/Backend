-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_invoices billing_invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_invoices"
    ADD CONSTRAINT "billing_invoices_invoice_number_key" UNIQUE ("invoice_number");


--

-- Name: billing_invoices billing_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_invoices"
    ADD CONSTRAINT "billing_invoices_pkey" PRIMARY KEY ("id");


--

-- Name: idx_billing_invoices_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_billing_invoices_user" ON "public"."billing_invoices" USING "btree" ("user_id", "status");


--

-- Name: billing_invoices billing_invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_invoices"
    ADD CONSTRAINT "billing_invoices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
