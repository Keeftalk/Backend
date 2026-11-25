-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: two_factor_login_challenges Users can view active login challenges for themselves; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view active login challenges for themselves" ON "public"."two_factor_login_challenges" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: two_factor_login_challenges; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."two_factor_login_challenges" ENABLE ROW LEVEL SECURITY;

--
