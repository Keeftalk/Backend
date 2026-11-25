-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: broadcasts Authenticated users can read broadcasts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can read broadcasts" ON "public"."broadcasts" FOR SELECT TO "authenticated" USING (true);


--

-- Name: broadcasts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."broadcasts" ENABLE ROW LEVEL SECURITY;

--
