-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_collection_ref book_collection_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_pkey" PRIMARY KEY ("book_id", "collection_id");


--

-- Name: book_collection_ref book_collection_ref_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;


--

-- Name: book_collection_ref book_collection_ref_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_collection_id_fkey" FOREIGN KEY ("collection_id") REFERENCES "public"."book_collections"("id") ON DELETE CASCADE;


--

-- Name: book_collection_ref book_collection_ref_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."book_collection_ref"
    ADD CONSTRAINT "book_collection_ref_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
