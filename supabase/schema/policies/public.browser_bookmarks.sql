-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: browser_bookmarks Users can manage their own bookmarks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own bookmarks" ON "public"."browser_bookmarks" USING (("auth"."uid"() = "user_id"));


--

-- Name: browser_bookmarks Users can manage their own browser bookmarks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own browser bookmarks" ON "public"."browser_bookmarks" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: browser_bookmarks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."browser_bookmarks" ENABLE ROW LEVEL SECURITY;

--
