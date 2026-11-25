-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_grace_uses habit_grace_uses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_grace_uses"
    ADD CONSTRAINT "habit_grace_uses_pkey" PRIMARY KEY ("id");


--

-- Name: habit_grace_uses_habit_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "habit_grace_uses_habit_id_idx" ON "public"."habit_grace_uses" USING "btree" ("habit_id");


--

-- Name: habit_grace_uses habit_grace_uses_habit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_grace_uses"
    ADD CONSTRAINT "habit_grace_uses_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "public"."habits"("id") ON DELETE CASCADE;


--
