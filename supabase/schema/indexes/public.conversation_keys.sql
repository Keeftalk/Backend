-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: conversation_keys conversation_keys_conversation_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_conversation_id_user_id_key" UNIQUE ("conversation_id", "user_id");


--

-- Name: conversation_keys conversation_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_pkey" PRIMARY KEY ("id");


--

-- Name: conversation_keys conversation_keys_user_id_conversation_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_user_id_conversation_id_key" UNIQUE ("user_id", "conversation_id");


--

-- Name: conversation_keys conversation_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."conversation_keys"
    ADD CONSTRAINT "conversation_keys_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
