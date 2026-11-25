-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_submissions store_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_submissions"
    ADD CONSTRAINT "store_submissions_pkey" PRIMARY KEY ("id");


--

-- Name: store_submissions store_submissions_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_submissions"
    ADD CONSTRAINT "store_submissions_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "public"."store_publishers"("id") ON DELETE CASCADE;


--
