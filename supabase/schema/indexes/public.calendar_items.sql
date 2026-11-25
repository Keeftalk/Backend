-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calendar_items calendar_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."calendar_items"
    ADD CONSTRAINT "calendar_items_pkey" PRIMARY KEY ("id");


--

-- Name: calendar_items calendar_items_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."calendar_items"
    ADD CONSTRAINT "calendar_items_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--

-- Name: calendar_items calendar_items_parent_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."calendar_items"
    ADD CONSTRAINT "calendar_items_parent_item_id_fkey" FOREIGN KEY ("parent_item_id") REFERENCES "public"."calendar_items"("id") ON DELETE SET NULL;


--
