-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_nicknames Internal Access Only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Internal Access Only" ON "public"."caller_nicknames" USING (false);


--

-- Name: caller_nicknames; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."caller_nicknames" ENABLE ROW LEVEL SECURITY;

--
