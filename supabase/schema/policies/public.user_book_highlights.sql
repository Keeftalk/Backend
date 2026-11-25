-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_highlights Users manage their own highlights; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own highlights" ON "public"."user_book_highlights" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_book_highlights; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_book_highlights" ENABLE ROW LEVEL SECURITY;

--
