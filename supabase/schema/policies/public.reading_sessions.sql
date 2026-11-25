-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: reading_sessions Users can manage their own reading sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own reading sessions" ON "public"."reading_sessions" USING (("auth"."uid"() = "user_id"));


--

-- Name: reading_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."reading_sessions" ENABLE ROW LEVEL SECURITY;

--
