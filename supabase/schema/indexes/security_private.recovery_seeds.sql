-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: recovery_seeds recovery_seeds_pkey; Type: CONSTRAINT; Schema: security_private; Owner: postgres
--

ALTER TABLE ONLY "security_private"."recovery_seeds"
    ADD CONSTRAINT "recovery_seeds_pkey" PRIMARY KEY ("user_id");


--

-- Name: recovery_seeds recovery_seeds_user_id_fkey; Type: FK CONSTRAINT; Schema: security_private; Owner: postgres
--

ALTER TABLE ONLY "security_private"."recovery_seeds"
    ADD CONSTRAINT "recovery_seeds_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
