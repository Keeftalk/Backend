-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: legal_documents Allow public read for active documents; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read for active documents" ON "public"."legal_documents" FOR SELECT TO "anon", "authenticated" USING (("is_active" = true));


--

-- Name: legal_documents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."legal_documents" ENABLE ROW LEVEL SECURITY;

--
