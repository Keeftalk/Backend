-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_books user_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_books"
    ADD CONSTRAINT "user_books_pkey" PRIMARY KEY ("user_id", "id");


--

-- Name: idx_user_books_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_books_updated_at" ON "public"."user_books" USING "btree" ("updated_at" DESC);


--

-- Name: idx_user_books_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_books_user_id" ON "public"."user_books" USING "btree" ("user_id");


--

-- Name: user_books user_books_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_books"
    ADD CONSTRAINT "user_books_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
