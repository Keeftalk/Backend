-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_extensions store_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_extensions"
    ADD CONSTRAINT "store_extensions_pkey" PRIMARY KEY ("id");


--

-- Name: store_extensions store_extensions_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_extensions"
    ADD CONSTRAINT "store_extensions_slug_key" UNIQUE ("slug");


--

-- Name: store_extensions store_extensions_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_extensions"
    ADD CONSTRAINT "store_extensions_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "public"."store_publishers"("id") ON DELETE CASCADE;


--
