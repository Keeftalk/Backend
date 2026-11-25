-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_pricing Authenticated users can read billing pricing; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can read billing pricing" ON "public"."billing_pricing" FOR SELECT TO "authenticated" USING (("is_active" = true));


--

-- Name: billing_pricing; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."billing_pricing" ENABLE ROW LEVEL SECURITY;

--
