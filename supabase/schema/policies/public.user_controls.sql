-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_controls Users can view their own controls; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own controls" ON "public"."user_controls" FOR SELECT USING (("auth"."uid"() = "user_id"));


--

-- Name: user_controls; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_controls" ENABLE ROW LEVEL SECURITY;

--
