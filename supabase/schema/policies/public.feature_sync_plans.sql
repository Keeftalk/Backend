-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: feature_sync_plans Public read feature_sync_plans; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read feature_sync_plans" ON "public"."feature_sync_plans" FOR SELECT USING (("enabled" = true));


--

-- Name: feature_sync_plans; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."feature_sync_plans" ENABLE ROW LEVEL SECURITY;

--
