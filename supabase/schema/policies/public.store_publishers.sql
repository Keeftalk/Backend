-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_publishers Public read approved publishers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read approved publishers" ON "public"."store_publishers" FOR SELECT USING (true);


--

-- Name: store_publishers Publishers manage own account; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Publishers manage own account" ON "public"."store_publishers" USING (("auth"."uid"() = "user_id"));


--

-- Name: store_publishers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_publishers" ENABLE ROW LEVEL SECURITY;

--
