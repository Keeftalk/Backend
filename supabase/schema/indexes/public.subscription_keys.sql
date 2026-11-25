-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_keys subscription_keys_key_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_keys"
    ADD CONSTRAINT "subscription_keys_key_hash_key" UNIQUE ("key_hash");


--

-- Name: subscription_keys subscription_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_keys"
    ADD CONSTRAINT "subscription_keys_pkey" PRIMARY KEY ("id");


--

-- Name: idx_subscription_keys_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_subscription_keys_hash" ON "public"."subscription_keys" USING "btree" ("key_hash");


--

-- Name: subscription_keys subscription_keys_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_keys"
    ADD CONSTRAINT "subscription_keys_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");


--
