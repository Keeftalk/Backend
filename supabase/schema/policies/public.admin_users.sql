-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: admin_users Users can read own admin status; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own admin status" ON "public"."admin_users" FOR SELECT USING (("auth"."uid"() = "id"));


--

-- Name: admin_users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."admin_users" ENABLE ROW LEVEL SECURITY;

--
