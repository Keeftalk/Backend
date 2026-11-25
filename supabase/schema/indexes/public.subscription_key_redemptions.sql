-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_key_redemptions one_redemption_per_user_per_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "one_redemption_per_user_per_key" UNIQUE ("key_id", "user_id");


--

-- Name: subscription_key_redemptions subscription_key_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "subscription_key_redemptions_pkey" PRIMARY KEY ("id");


--

-- Name: idx_key_redemptions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_key_redemptions_user" ON "public"."subscription_key_redemptions" USING "btree" ("user_id");


--

-- Name: subscription_key_redemptions subscription_key_redemptions_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "subscription_key_redemptions_key_id_fkey" FOREIGN KEY ("key_id") REFERENCES "public"."subscription_keys"("id") ON DELETE CASCADE;


--

-- Name: subscription_key_redemptions subscription_key_redemptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subscription_key_redemptions"
    ADD CONSTRAINT "subscription_key_redemptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
