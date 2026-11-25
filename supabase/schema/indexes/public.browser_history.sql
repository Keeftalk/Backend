-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: browser_history browser_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."browser_history"
    ADD CONSTRAINT "browser_history_pkey" PRIMARY KEY ("userId");


--

-- Name: idx_browser_history_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_browser_history_user_id" ON "public"."browser_history" USING "btree" ("user_id");


--

-- Name: idx_browser_history_visit_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_browser_history_visit_time" ON "public"."browser_history" USING "btree" ("visitTime" DESC);


--

-- Name: browser_history browser_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."browser_history"
    ADD CONSTRAINT "browser_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
