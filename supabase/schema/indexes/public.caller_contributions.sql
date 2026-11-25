-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_contributions caller_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_contributions"
    ADD CONSTRAINT "caller_contributions_pkey" PRIMARY KEY ("contributor_user_id", "phone_hash", "field_type", "candidate_value");


--

-- Name: caller_contributions caller_contributions_contributor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_contributions"
    ADD CONSTRAINT "caller_contributions_contributor_user_id_fkey" FOREIGN KEY ("contributor_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
