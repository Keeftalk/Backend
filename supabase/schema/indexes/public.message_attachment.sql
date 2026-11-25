-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_attachment message_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_attachment"
    ADD CONSTRAINT "message_attachment_pkey" PRIMARY KEY ("id");


--

-- Name: message_attachment message_attachment_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_attachment"
    ADD CONSTRAINT "message_attachment_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");


--

-- Name: message_attachment message_attachment_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_attachment"
    ADD CONSTRAINT "message_attachment_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;


--
