-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_checkins habit_checkins_habit_id_epoch_day_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_checkins"
    ADD CONSTRAINT "habit_checkins_habit_id_epoch_day_key" UNIQUE ("habit_id", "epoch_day");


--

-- Name: habit_checkins habit_checkins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_checkins"
    ADD CONSTRAINT "habit_checkins_pkey" PRIMARY KEY ("id");


--

-- Name: habit_checkins_habit_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "habit_checkins_habit_id_idx" ON "public"."habit_checkins" USING "btree" ("habit_id");


--

-- Name: habit_checkins habit_checkins_habit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_checkins"
    ADD CONSTRAINT "habit_checkins_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;


--
