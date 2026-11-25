-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_schedules habit_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_schedules"
    ADD CONSTRAINT "habit_schedules_pkey" PRIMARY KEY ("id");


--

-- Name: habit_schedules_habit_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "habit_schedules_habit_id_idx" ON "public"."habit_schedules" USING "btree" ("habit_id");


--

-- Name: habit_schedules habit_schedules_habit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_schedules"
    ADD CONSTRAINT "habit_schedules_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;


--
