-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_2fa_factors user_2fa_factors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_2fa_factors"
    ADD CONSTRAINT "user_2fa_factors_pkey" PRIMARY KEY ("id");


--

-- Name: user_2fa_factors user_2fa_factors_user_id_factor_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_2fa_factors"
    ADD CONSTRAINT "user_2fa_factors_user_id_factor_type_key" UNIQUE ("user_id", "factor_type");


--

-- Name: user_2fa_factors user_2fa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_2fa_factors"
    ADD CONSTRAINT "user_2fa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
