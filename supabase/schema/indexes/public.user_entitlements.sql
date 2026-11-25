-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_entitlements user_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_entitlements"
    ADD CONSTRAINT "user_entitlements_pkey" PRIMARY KEY ("id");


--

-- Name: idx_user_entitlements_user_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_entitlements_user_status" ON "public"."user_entitlements" USING "btree" ("user_id", "status");


--

-- Name: user_entitlements user_entitlements_source_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_entitlements"
    ADD CONSTRAINT "user_entitlements_source_key_id_fkey" FOREIGN KEY ("source_key_id") REFERENCES "public"."subscription_keys"("id");


--

-- Name: user_entitlements user_entitlements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_entitlements"
    ADD CONSTRAINT "user_entitlements_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
