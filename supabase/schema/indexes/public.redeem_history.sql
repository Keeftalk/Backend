-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: redeem_history redeem_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."redeem_history"
    ADD CONSTRAINT "redeem_history_pkey" PRIMARY KEY ("id");


--

-- Name: redeem_history redeem_history_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."redeem_history"
    ADD CONSTRAINT "redeem_history_code_id_fkey" FOREIGN KEY ("code_id") REFERENCES "public"."redeem_codes"("id") ON DELETE SET NULL;


--

-- Name: redeem_history redeem_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."redeem_history"
    ADD CONSTRAINT "redeem_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
