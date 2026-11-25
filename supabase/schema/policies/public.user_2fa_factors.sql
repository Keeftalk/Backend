-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_2fa_factors Users can view their own 2fa factors; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own 2fa factors" ON "public"."user_2fa_factors" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_2fa_factors; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_2fa_factors" ENABLE ROW LEVEL SECURITY;

--
