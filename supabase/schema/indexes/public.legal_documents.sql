-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: legal_documents legal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."legal_documents"
    ADD CONSTRAINT "legal_documents_pkey" PRIMARY KEY ("id");


--

-- Name: one_active_document_per_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "one_active_document_per_type" ON "public"."legal_documents" USING "btree" ("type") WHERE ("is_active" = true);


--
