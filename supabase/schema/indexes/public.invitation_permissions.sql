-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: invitation_permissions invitation_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."invitation_permissions"
    ADD CONSTRAINT "invitation_permissions_pkey" PRIMARY KEY ("id");


--

-- Name: invitation_permissions invitation_permissions_invitation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."invitation_permissions"
    ADD CONSTRAINT "invitation_permissions_invitation_id_fkey" FOREIGN KEY ("invitation_id") REFERENCES "public"."calendar_invitations"("id") ON DELETE CASCADE;


--
