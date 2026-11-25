-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_contributions Internal Access Only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Internal Access Only" ON "public"."caller_contributions" USING (false);


--

-- Name: caller_contributions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."caller_contributions" ENABLE ROW LEVEL SECURITY;

--
