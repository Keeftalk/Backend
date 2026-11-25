-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_controls user_controls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_pkey" PRIMARY KEY ("id");


--

-- Name: user_controls user_controls_user_id_supervisor_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_user_id_supervisor_id_key" UNIQUE ("user_id", "supervisor_id");


--

-- Name: user_controls user_controls_supervisor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_supervisor_id_fkey" FOREIGN KEY ("supervisor_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--

-- Name: user_controls user_controls_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_controls"
    ADD CONSTRAINT "user_controls_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
