-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_key_redemptions Users can view own redemptions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own redemptions" ON "public"."subscription_key_redemptions" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: subscription_key_redemptions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."subscription_key_redemptions" ENABLE ROW LEVEL SECURITY;

--
