-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_ratings Anyone insert ratings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone insert ratings" ON "public"."store_ratings" FOR INSERT WITH CHECK (true);


--

-- Name: store_ratings Public read ratings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read ratings" ON "public"."store_ratings" FOR SELECT USING (true);


--

-- Name: store_ratings Users insert/update own ratings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users insert/update own ratings" ON "public"."store_ratings" USING (("auth"."uid"() = "user_id"));


--

-- Name: store_ratings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_ratings" ENABLE ROW LEVEL SECURITY;

--
