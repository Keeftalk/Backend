-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_2fa_backup_codes user_2fa_backup_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_2fa_backup_codes"
    ADD CONSTRAINT "user_2fa_backup_codes_pkey" PRIMARY KEY ("id");


--

-- Name: user_2fa_backup_codes user_2fa_backup_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_2fa_backup_codes"
    ADD CONSTRAINT "user_2fa_backup_codes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
