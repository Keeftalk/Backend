-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: family_groups family_groups_owner_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."family_groups"
    ADD CONSTRAINT "family_groups_owner_id_key" UNIQUE ("owner_id");


--

-- Name: family_groups family_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."family_groups"
    ADD CONSTRAINT "family_groups_pkey" PRIMARY KEY ("id");


--

-- Name: idx_family_groups_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_family_groups_owner_id" ON "public"."family_groups" USING "btree" ("owner_id");


--
