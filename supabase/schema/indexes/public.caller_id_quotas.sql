-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_id_quotas caller_id_quotas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_id_quotas"
    ADD CONSTRAINT "caller_id_quotas_pkey" PRIMARY KEY ("user_id");


--

-- Name: caller_id_quotas caller_id_quotas_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_id_quotas"
    ADD CONSTRAINT "caller_id_quotas_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
