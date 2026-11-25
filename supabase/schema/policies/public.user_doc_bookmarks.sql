-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_bookmarks Users manage their own doc bookmarks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own doc bookmarks" ON "public"."user_doc_bookmarks" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_doc_bookmarks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_doc_bookmarks" ENABLE ROW LEVEL SECURITY;

--
