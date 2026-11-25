-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_releases store_releases_extension_version_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_releases"
    ADD CONSTRAINT "store_releases_extension_version_key" UNIQUE ("extension_id", "version");


--

-- Name: store_releases store_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_releases"
    ADD CONSTRAINT "store_releases_pkey" PRIMARY KEY ("id");


--

-- Name: store_releases store_releases_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_releases"
    ADD CONSTRAINT "store_releases_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;


--
