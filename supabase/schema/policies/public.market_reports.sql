-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_reports Users can create reports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create reports" ON "public"."market_reports" FOR INSERT WITH CHECK ((("auth"."uid"())::"text" = ("reporter_id")::"text"));


--

-- Name: market_reports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_reports" ENABLE ROW LEVEL SECURITY;

--
