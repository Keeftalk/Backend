-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_link_previews message_link_previews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "message_link_previews_pkey" PRIMARY KEY ("id");


--

-- Name: message_link_previews unique_message_link_preview; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "unique_message_link_preview" UNIQUE ("message_id", "link_preview_id");


--

-- Name: message_link_previews message_link_previews_link_preview_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "message_link_previews_link_preview_id_fkey" FOREIGN KEY ("link_preview_id") REFERENCES "public"."link_previews"("id");


--

-- Name: message_link_previews message_link_previews_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_link_previews"
    ADD CONSTRAINT "message_link_previews_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;


--
