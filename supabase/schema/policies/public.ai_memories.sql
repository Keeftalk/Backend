-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_memories Users can manage their own ai_memories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own ai_memories" ON "public"."ai_memories" USING (("auth"."uid"() = "user_id"));


--

-- Name: ai_memories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."ai_memories" ENABLE ROW LEVEL SECURITY;

--
