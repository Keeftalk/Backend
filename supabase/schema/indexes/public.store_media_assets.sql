-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_media_assets store_media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_media_assets"
    ADD CONSTRAINT "store_media_assets_pkey" PRIMARY KEY ("id");


--

-- Name: store_media_assets store_media_assets_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_media_assets"
    ADD CONSTRAINT "store_media_assets_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;


--
