-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_bookmarks user_doc_bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_doc_bookmarks"
    ADD CONSTRAINT "user_doc_bookmarks_pkey" PRIMARY KEY ("user_id", "doc_id", "page_or_position");


--

-- Name: idx_user_doc_bookmarks_user_doc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_doc_bookmarks_user_doc" ON "public"."user_doc_bookmarks" USING "btree" ("user_id", "doc_id");


--

-- Name: user_doc_bookmarks user_doc_bookmarks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_doc_bookmarks"
    ADD CONSTRAINT "user_doc_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
