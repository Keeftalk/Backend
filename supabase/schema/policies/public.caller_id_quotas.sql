-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_id_quotas Internal Access Only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Internal Access Only" ON "public"."caller_id_quotas" USING (false);


--

-- Name: caller_id_quotas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."caller_id_quotas" ENABLE ROW LEVEL SECURITY;

--
