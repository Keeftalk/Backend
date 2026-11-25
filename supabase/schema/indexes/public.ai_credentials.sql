-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_credentials ai_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."ai_credentials"
    ADD CONSTRAINT "ai_credentials_pkey" PRIMARY KEY ("id");


--

-- Name: ai_credentials ai_credentials_user_id_provider_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."ai_credentials"
    ADD CONSTRAINT "ai_credentials_user_id_provider_id_key" UNIQUE ("user_id", "provider_id");


--

-- Name: ai_credentials ai_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."ai_credentials"
    ADD CONSTRAINT "ai_credentials_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
