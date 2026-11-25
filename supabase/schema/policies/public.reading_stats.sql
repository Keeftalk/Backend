-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: reading_stats Users can manage their own reading stats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own reading stats" ON "public"."reading_stats" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: reading_stats; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."reading_stats" ENABLE ROW LEVEL SECURITY;

--
