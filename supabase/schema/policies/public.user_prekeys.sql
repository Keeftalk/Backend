-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_prekeys Public pre-key read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public pre-key read access" ON "public"."user_prekeys" FOR SELECT TO "authenticated" USING (true);


--

-- Name: user_prekeys Users can manage own pre-keys; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage own pre-keys" ON "public"."user_prekeys" TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_prekeys; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_prekeys" ENABLE ROW LEVEL SECURITY;

--
