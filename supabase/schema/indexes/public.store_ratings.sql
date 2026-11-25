-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_ratings store_ratings_extension_user_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_extension_user_key" UNIQUE ("extension_id", "user_id");


--

-- Name: store_ratings store_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_pkey" PRIMARY KEY ("id");


--

-- Name: store_ratings store_ratings_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_extension_id_fkey" FOREIGN KEY ("extension_id") REFERENCES "public"."store_extensions"("id") ON DELETE CASCADE;


--

-- Name: store_ratings store_ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."store_ratings"
    ADD CONSTRAINT "store_ratings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
