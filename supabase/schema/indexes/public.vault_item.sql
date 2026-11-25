-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_item vault_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_pkey" PRIMARY KEY ("id");


--

-- Name: vault_item vault_item_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");


--

-- Name: vault_item vault_item_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_folder_id_fkey" FOREIGN KEY ("folder_id") REFERENCES "public"."vault_folders"("id") ON DELETE SET NULL;


--

-- Name: vault_item vault_item_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."vault_item"
    ADD CONSTRAINT "vault_item_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
