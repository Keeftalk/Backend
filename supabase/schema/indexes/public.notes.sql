-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notes"
    ADD CONSTRAINT "notes_pkey" PRIMARY KEY ("id");


--

-- Name: notes_owner_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notes_owner_id_idx" ON "public"."notes" USING "btree" ("owner_id");


--

-- Name: notes_owner_updated_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notes_owner_updated_idx" ON "public"."notes" USING "btree" ("owner_id", "updated_at");


--

-- Name: notes_updated_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notes_updated_at_idx" ON "public"."notes" USING "btree" ("updated_at");


--

-- Name: notes notes_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notes"
    ADD CONSTRAINT "notes_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
