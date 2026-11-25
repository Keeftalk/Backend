-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_spam_reporters caller_spam_reporters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_spam_reporters"
    ADD CONSTRAINT "caller_spam_reporters_pkey" PRIMARY KEY ("user_id", "phone_hash");


--

-- Name: caller_spam_reporters caller_spam_reporters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_spam_reporters"
    ADD CONSTRAINT "caller_spam_reporters_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
