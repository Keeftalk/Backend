-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_balances Users can view own balance; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own balance" ON "public"."billing_balances" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: billing_balances; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."billing_balances" ENABLE ROW LEVEL SECURITY;

--
