-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_metadata Allow public read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read" ON "public"."subscription_metadata" FOR SELECT TO "anon", "authenticated" USING (true);


--

-- Name: subscription_metadata Allow public read access for subscription plans; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access for subscription plans" ON "public"."subscription_metadata" FOR SELECT TO "anon" USING (true);


--

-- Name: subscription_metadata Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."subscription_metadata" FOR SELECT TO "anon" USING (true);


--

-- Name: subscription_metadata; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."subscription_metadata" ENABLE ROW LEVEL SECURITY;

--
