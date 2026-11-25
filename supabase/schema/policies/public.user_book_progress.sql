-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_book_progress Users manage their own page progress; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own page progress" ON "public"."user_book_progress" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_book_progress; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_book_progress" ENABLE ROW LEVEL SECURITY;

--
