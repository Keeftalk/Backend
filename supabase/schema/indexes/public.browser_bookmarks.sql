-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: browser_bookmarks browser_bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."browser_bookmarks"
    ADD CONSTRAINT "browser_bookmarks_pkey" PRIMARY KEY ("userId");


--

-- Name: idx_browser_bookmarks_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_browser_bookmarks_user_id" ON "public"."browser_bookmarks" USING "btree" ("user_id");


--

-- Name: browser_bookmarks browser_bookmarks_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."browser_bookmarks"
    ADD CONSTRAINT "browser_bookmarks_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."browser_bookmarks"("userId");


--

-- Name: browser_bookmarks browser_bookmarks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."browser_bookmarks"
    ADD CONSTRAINT "browser_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
