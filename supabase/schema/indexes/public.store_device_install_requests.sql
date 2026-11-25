-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_device_install_requests store_device_install_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_device_install_requests"
    ADD CONSTRAINT "store_device_install_requests_pkey" PRIMARY KEY ("id");


--

-- Name: store_device_install_requests store_device_install_requests_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_device_install_requests"
    ADD CONSTRAINT "store_device_install_requests_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;


--

-- Name: store_device_install_requests store_device_install_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_device_install_requests"
    ADD CONSTRAINT "store_device_install_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
