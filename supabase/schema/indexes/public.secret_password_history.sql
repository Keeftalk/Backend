-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_password_history secret_password_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_password_history"
    ADD CONSTRAINT "secret_password_history_pkey" PRIMARY KEY ("id");


--

-- Name: idx_secret_pw_hist_cred; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_pw_hist_cred" ON "public"."secret_password_history" USING "btree" ("credential_id");


--

-- Name: idx_secret_pw_hist_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_pw_hist_user" ON "public"."secret_password_history" USING "btree" ("user_id");


--

-- Name: secret_password_history secret_password_history_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_password_history"
    ADD CONSTRAINT "secret_password_history_credential_id_fkey" FOREIGN KEY ("credential_id") REFERENCES "public"."secret_credentials"("id") ON DELETE CASCADE;


--

-- Name: secret_password_history secret_password_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_password_history"
    ADD CONSTRAINT "secret_password_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
