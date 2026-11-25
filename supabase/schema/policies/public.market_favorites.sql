-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_favorites Users manage own favorites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage own favorites" ON "public"."market_favorites" USING (("auth"."uid"() = "user_id"));


--

-- Name: market_favorites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_favorites" ENABLE ROW LEVEL SECURITY;

--
