-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_quotes book_quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_quotes"
    ADD CONSTRAINT "book_quotes_pkey" PRIMARY KEY ("id");


--

-- Name: idx_book_quotes_book_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_book_quotes_book_id" ON "public"."book_quotes" USING "btree" ("book_id");


--

-- Name: book_quotes book_quotes_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_quotes"
    ADD CONSTRAINT "book_quotes_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;


--

-- Name: book_quotes book_quotes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_quotes"
    ADD CONSTRAINT "book_quotes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
