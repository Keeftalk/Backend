-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_installations Anyone insert installations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone insert installations" ON "public"."store_installations" FOR INSERT WITH CHECK (true);


--

-- Name: store_installations Users view own installations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users view own installations" ON "public"."store_installations" USING (("auth"."uid"() = "user_id"));


--

-- Name: store_installations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_installations" ENABLE ROW LEVEL SECURITY;

--
