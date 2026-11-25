-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: relationship_intelligence relationship_intelligence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."relationship_intelligence"
    ADD CONSTRAINT "relationship_intelligence_pkey" PRIMARY KEY ("user_a", "user_b");


--

-- Name: idx_relationship_intelligence_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_relationship_intelligence_lookup" ON "public"."relationship_intelligence" USING "btree" ("user_a", "user_b");


--
