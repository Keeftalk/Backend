-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_device_install_requests Users manage own install requests; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage own install requests" ON "public"."store_device_install_requests" USING (("auth"."uid"() = "user_id"));


--

-- Name: store_device_install_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_device_install_requests" ENABLE ROW LEVEL SECURITY;

--
