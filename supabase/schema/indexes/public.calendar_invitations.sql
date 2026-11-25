-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calendar_invitations calendar_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."calendar_invitations"
    ADD CONSTRAINT "calendar_invitations_pkey" PRIMARY KEY ("id");


--

-- Name: calendar_invitations calendar_invitations_from_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."calendar_invitations"
    ADD CONSTRAINT "calendar_invitations_from_user_id_fkey" FOREIGN KEY ("from_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: calendar_invitations calendar_invitations_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."calendar_invitations"
    ADD CONSTRAINT "calendar_invitations_to_user_id_fkey" FOREIGN KEY ("to_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
