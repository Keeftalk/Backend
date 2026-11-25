-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_books Users manage their own books; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own books" ON "public"."user_books" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_books; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_books" ENABLE ROW LEVEL SECURITY;

--
