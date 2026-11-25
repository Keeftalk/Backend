-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_credentials Users can manage their own ai_credentials; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own ai_credentials" ON "public"."ai_credentials" USING (("auth"."uid"() = "user_id"));


--

-- Name: ai_credentials; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."ai_credentials" ENABLE ROW LEVEL SECURITY;

--
