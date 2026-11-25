-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_saved Users can remove saved market items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can remove saved market items" ON "public"."market_saved" FOR DELETE USING ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: market_saved Users can save market items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can save market items" ON "public"."market_saved" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: market_saved Users can view own saved items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own saved items" ON "public"."market_saved" FOR SELECT USING ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: market_saved; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_saved" ENABLE ROW LEVEL SECURITY;

--
