-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_pkey" PRIMARY KEY ("id");


--

-- Name: idx_files_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_files_hash" ON "public"."files" USING "btree" ("file_hash");


--

-- Name: idx_files_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_files_owner" ON "public"."files" USING "btree" ("owner_id");


--

-- Name: files files_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id");


--
