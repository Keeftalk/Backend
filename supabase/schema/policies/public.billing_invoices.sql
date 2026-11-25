-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_invoices Users can view own invoices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own invoices" ON "public"."billing_invoices" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: billing_invoices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."billing_invoices" ENABLE ROW LEVEL SECURITY;

--
