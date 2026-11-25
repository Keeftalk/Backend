-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_identities Internal Access Only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Internal Access Only" ON "public"."caller_identities" USING (false);


--

-- Name: caller_identities; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."caller_identities" ENABLE ROW LEVEL SECURITY;

--
