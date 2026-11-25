-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_backup_codes secret_backup_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_backup_codes"
    ADD CONSTRAINT "secret_backup_codes_pkey" PRIMARY KEY ("id");


--

-- Name: idx_secret_backup_codes_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_backup_codes_user" ON "public"."secret_backup_codes" USING "btree" ("user_id");


--

-- Name: secret_backup_codes secret_backup_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_backup_codes"
    ADD CONSTRAINT "secret_backup_codes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
