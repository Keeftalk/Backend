-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_docs user_docs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_docs"
    ADD CONSTRAINT "user_docs_pkey" PRIMARY KEY ("user_id", "id");


--

-- Name: idx_user_docs_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_docs_updated_at" ON "public"."user_docs" USING "btree" ("updated_at" DESC);


--

-- Name: idx_user_docs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_docs_user_id" ON "public"."user_docs" USING "btree" ("user_id");


--

-- Name: user_docs user_docs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_docs"
    ADD CONSTRAINT "user_docs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
