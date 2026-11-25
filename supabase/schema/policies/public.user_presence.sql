-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_presence Admins can read all presence; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read all presence" ON "public"."user_presence" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admin_users"
  WHERE ("admin_users"."id" = "auth"."uid"()))));


--

-- Name: user_presence Users can update own presence; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own presence" ON "public"."user_presence" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_presence; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_presence" ENABLE ROW LEVEL SECURITY;

--
