-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: two_factor_login_challenges two_factor_login_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."two_factor_login_challenges"
    ADD CONSTRAINT "two_factor_login_challenges_pkey" PRIMARY KEY ("id");


--

-- Name: two_factor_login_challenges two_factor_login_challenges_verification_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."two_factor_login_challenges"
    ADD CONSTRAINT "two_factor_login_challenges_verification_token_key" UNIQUE ("verification_token");


--

-- Name: two_factor_login_challenges two_factor_login_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."two_factor_login_challenges"
    ADD CONSTRAINT "two_factor_login_challenges_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
