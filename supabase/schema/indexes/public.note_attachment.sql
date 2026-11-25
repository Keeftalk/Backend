-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: note_attachment note_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."note_attachment"
    ADD CONSTRAINT "note_attachment_pkey" PRIMARY KEY ("id");


--

-- Name: note_attachment note_attachment_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."note_attachment"
    ADD CONSTRAINT "note_attachment_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id");


--

-- Name: note_attachment note_attachment_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."note_attachment"
    ADD CONSTRAINT "note_attachment_note_id_fkey" FOREIGN KEY ("note_id") REFERENCES "public"."notes"("id") ON DELETE CASCADE;


--
