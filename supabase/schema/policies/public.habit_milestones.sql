-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_milestones Users manage own habit milestones; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage own habit milestones" ON "public"."habit_milestones" TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("user_id" = ( SELECT "auth"."uid"() AS "uid")));


--

-- Name: habit_milestones; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."habit_milestones" ENABLE ROW LEVEL SECURITY;

--
