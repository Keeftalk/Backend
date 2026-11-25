-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: login_attempts Users can view their own login attempts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own login attempts" ON "public"."login_attempts" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: login_attempts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."login_attempts" ENABLE ROW LEVEL SECURITY;

--
