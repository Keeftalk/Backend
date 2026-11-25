-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_reports chat_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_reports"
    ADD CONSTRAINT "chat_reports_pkey" PRIMARY KEY ("id");


--

-- Name: chat_reports chat_reports_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_reports"
    ADD CONSTRAINT "chat_reports_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id");


--

-- Name: chat_reports chat_reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_reports"
    ADD CONSTRAINT "chat_reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "auth"."users"("id");


--
