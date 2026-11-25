-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_usage Users can view own usage; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own usage" ON "public"."billing_usage" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: billing_usage; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."billing_usage" ENABLE ROW LEVEL SECURITY;

--
