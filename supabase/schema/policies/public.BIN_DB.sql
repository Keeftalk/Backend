-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: BIN_DB Allow read access to BIN_DB; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow read access to BIN_DB" ON "public"."BIN_DB" FOR SELECT TO "anon", "authenticated" USING (true);


--

-- Name: BIN_DB; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."BIN_DB" ENABLE ROW LEVEL SECURITY;

--
