-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: redeem_history Users can view own redemption history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own redemption history" ON "public"."redeem_history" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: redeem_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."redeem_history" ENABLE ROW LEVEL SECURITY;

--
