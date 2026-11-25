-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_feature_entitlements Users read own entitlements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users read own entitlements" ON "public"."user_feature_entitlements" FOR SELECT USING ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: user_feature_entitlements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_feature_entitlements" ENABLE ROW LEVEL SECURITY;

--
