-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_usage billing_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_usage"
    ADD CONSTRAINT "billing_usage_pkey" PRIMARY KEY ("id");


--

-- Name: idx_billing_usage_user_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_billing_usage_user_period" ON "public"."billing_usage" USING "btree" ("user_id", "period_start", "period_end");


--

-- Name: billing_usage billing_usage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_usage"
    ADD CONSTRAINT "billing_usage_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
