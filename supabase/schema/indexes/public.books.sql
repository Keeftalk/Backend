-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_pkey" PRIMARY KEY ("id");


--

-- Name: idx_books_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_books_user_id" ON "public"."books" USING "btree" ("user_id");


--

-- Name: idx_books_vault_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_books_vault_file_id" ON "public"."books" USING "btree" ("vault_file_id");


--

-- Name: books books_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: books books_vault_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_vault_file_id_fkey" FOREIGN KEY ("vault_file_id") REFERENCES "public"."vault_items"("id") ON DELETE CASCADE;


--
