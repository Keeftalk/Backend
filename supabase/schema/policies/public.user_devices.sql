-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_devices Users manage own devices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage own devices" ON "public"."user_devices" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_devices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_devices" ENABLE ROW LEVEL SECURITY;

--
