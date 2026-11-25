-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_milestones habit_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_milestones"
    ADD CONSTRAINT "habit_milestones_pkey" PRIMARY KEY ("user_id", "key");


--

-- Name: habit_milestones habit_milestones_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."habit_milestones"
    ADD CONSTRAINT "habit_milestones_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
