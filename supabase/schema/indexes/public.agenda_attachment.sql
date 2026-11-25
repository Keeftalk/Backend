-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: agenda_attachment agenda_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."agenda_attachment"
    ADD CONSTRAINT "agenda_attachment_pkey" PRIMARY KEY ("id");


--

-- Name: agenda_attachment agenda_attachment_agenda_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."agenda_attachment"
    ADD CONSTRAINT "agenda_attachment_agenda_event_id_fkey" FOREIGN KEY ("agenda_event_id") REFERENCES "public"."calendar_items"("id") ON DELETE CASCADE;


--

-- Name: agenda_attachment agenda_attachment_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."agenda_attachment"
    ADD CONSTRAINT "agenda_attachment_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");


--
