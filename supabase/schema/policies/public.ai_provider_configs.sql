-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: ai_provider_configs Users can manage their own ai_provider_configs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own ai_provider_configs" ON "public"."ai_provider_configs" USING (("auth"."uid"() = "user_id"));


--

-- Name: ai_provider_configs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."ai_provider_configs" ENABLE ROW LEVEL SECURITY;

--
