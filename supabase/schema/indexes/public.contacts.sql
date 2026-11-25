-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_pkey" PRIMARY KEY ("id", "owner_id");


--

-- Name: idx_contacts_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_contacts_owner_id" ON "public"."contacts" USING "btree" ("owner_id");


--

-- Name: idx_contacts_owner_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_contacts_owner_search" ON "public"."contacts" USING "btree" ("owner_id", "is_keeftalk_user");


--

-- Name: idx_contacts_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_contacts_phone" ON "public"."contacts" USING "btree" ("phone");


--

-- Name: contacts contacts_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
