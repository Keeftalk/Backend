-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_recovery_seeds user_recovery_seeds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_recovery_seeds"
    ADD CONSTRAINT "user_recovery_seeds_pkey" PRIMARY KEY ("user_id");


--

-- Name: user_recovery_seeds user_recovery_seeds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_recovery_seeds"
    ADD CONSTRAINT "user_recovery_seeds_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
