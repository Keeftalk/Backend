-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_chat_settings ai_chat_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."ai_chat_settings"
    ADD CONSTRAINT "ai_chat_settings_pkey" PRIMARY KEY ("chat_id");


--

-- Name: ai_chat_settings ai_chat_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."ai_chat_settings"
    ADD CONSTRAINT "ai_chat_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
