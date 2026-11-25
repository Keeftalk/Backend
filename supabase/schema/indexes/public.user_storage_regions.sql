-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_storage_regions user_storage_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_storage_regions"
    ADD CONSTRAINT "user_storage_regions_pkey" PRIMARY KEY ("user_id");


--

-- Name: idx_user_storage_regions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_storage_regions_user_id" ON "public"."user_storage_regions" USING "btree" ("user_id");


--

-- Name: user_storage_regions user_storage_regions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_storage_regions"
    ADD CONSTRAINT "user_storage_regions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
