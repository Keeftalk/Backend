-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: official_broadcast_actions official_broadcast_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."official_broadcast_actions"
    ADD CONSTRAINT "official_broadcast_actions_pkey" PRIMARY KEY ("id");


--

-- Name: official_broadcast_actions official_broadcast_actions_broadcast_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."official_broadcast_actions"
    ADD CONSTRAINT "official_broadcast_actions_broadcast_id_fkey" FOREIGN KEY ("broadcast_id") REFERENCES "public"."broadcasts"("id") ON DELETE CASCADE;


--
