-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_visibility message_visibility_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_visibility"
    ADD CONSTRAINT "message_visibility_pkey" PRIMARY KEY ("message_id", "user_id");


--

-- Name: message_visibility message_visibility_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_visibility"
    ADD CONSTRAINT "message_visibility_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
