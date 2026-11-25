-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_time_tracking user_time_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_time_tracking"
    ADD CONSTRAINT "user_time_tracking_pkey" PRIMARY KEY ("user_id", "epoch_day", "feature_key");


--

-- Name: user_time_tracking user_time_tracking_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_time_tracking"
    ADD CONSTRAINT "user_time_tracking_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
