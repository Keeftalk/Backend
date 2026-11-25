-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_credentials secret_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_credentials"
    ADD CONSTRAINT "secret_credentials_pkey" PRIMARY KEY ("id");


--

-- Name: idx_secret_credentials_cat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_credentials_cat" ON "public"."secret_credentials" USING "btree" ("category");


--

-- Name: idx_secret_credentials_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_secret_credentials_user" ON "public"."secret_credentials" USING "btree" ("user_id");


--

-- Name: secret_credentials secret_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secret_credentials"
    ADD CONSTRAINT "secret_credentials_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
