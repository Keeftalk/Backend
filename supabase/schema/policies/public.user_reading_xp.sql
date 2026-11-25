-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_reading_xp Authenticated users can read global XP leaderboard; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can read global XP leaderboard" ON "public"."user_reading_xp" FOR SELECT TO "authenticated" USING (true);


--

-- Name: user_reading_xp Users can manage their own XP; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own XP" ON "public"."user_reading_xp" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_reading_xp; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_reading_xp" ENABLE ROW LEVEL SECURITY;

--
