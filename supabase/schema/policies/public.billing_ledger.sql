-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_ledger Users can view own ledger; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own ledger" ON "public"."billing_ledger" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: billing_ledger; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."billing_ledger" ENABLE ROW LEVEL SECURITY;

--
