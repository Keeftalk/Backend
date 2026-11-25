-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: system_metrics Admins can read system metrics; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read system metrics" ON "public"."system_metrics" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admin_users"
  WHERE ("admin_users"."id" = "auth"."uid"()))));


--

-- Name: system_metrics; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."system_metrics" ENABLE ROW LEVEL SECURITY;

--
