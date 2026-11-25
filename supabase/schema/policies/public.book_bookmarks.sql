-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_bookmarks Users can manage their own bookmarks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own bookmarks" ON "public"."book_bookmarks" USING (("auth"."uid"() = "user_id"));


--

-- Name: book_bookmarks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."book_bookmarks" ENABLE ROW LEVEL SECURITY;

--
