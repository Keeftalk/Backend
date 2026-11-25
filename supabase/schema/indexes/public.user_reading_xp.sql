-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_reading_xp user_reading_xp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_reading_xp"
    ADD CONSTRAINT "user_reading_xp_pkey" PRIMARY KEY ("user_id");


--

-- Name: idx_user_reading_xp_total_xp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_reading_xp_total_xp" ON "public"."user_reading_xp" USING "btree" ("total_xp" DESC);


--

-- Name: user_reading_xp user_reading_xp_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_reading_xp"
    ADD CONSTRAINT "user_reading_xp_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
