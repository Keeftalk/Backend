-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: link_previews link_previews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."link_previews"
    ADD CONSTRAINT "link_previews_pkey" PRIMARY KEY ("id");


--

-- Name: idx_link_previews_normalized_url; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "idx_link_previews_normalized_url" ON "public"."link_previews" USING "btree" ("normalized_url");


--
