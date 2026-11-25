-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_payments Users can view own payments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own payments" ON "public"."billing_payments" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: billing_payments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."billing_payments" ENABLE ROW LEVEL SECURITY;

--
