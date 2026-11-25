-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_totp_accounts secret_totp_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_totp_accounts"
    ADD CONSTRAINT "secret_totp_accounts_pkey" PRIMARY KEY ("id");


--

-- Name: idx_secret_totp_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_totp_user" ON "public"."secret_totp_accounts" USING "btree" ("user_id");


--

-- Name: secret_totp_accounts secret_totp_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_totp_accounts"
    ADD CONSTRAINT "secret_totp_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
