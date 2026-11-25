-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_bookmarks user_book_bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_book_bookmarks"
    ADD CONSTRAINT "user_book_bookmarks_pkey" PRIMARY KEY ("user_id", "book_id", "page_number");


--

-- Name: idx_user_book_bookmarks_user_book; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_book_bookmarks_user_book" ON "public"."user_book_bookmarks" USING "btree" ("user_id", "book_id");


--

-- Name: user_book_bookmarks user_book_bookmarks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_book_bookmarks"
    ADD CONSTRAINT "user_book_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
