-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_settings user_doc_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_doc_settings"
    ADD CONSTRAINT "user_doc_settings_pkey" PRIMARY KEY ("user_id");


--

-- Name: user_doc_settings user_doc_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_doc_settings"
    ADD CONSTRAINT "user_doc_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
