-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_entitlements Users can view own entitlements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own entitlements" ON "public"."user_entitlements" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: user_entitlements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_entitlements" ENABLE ROW LEVEL SECURITY;

--
