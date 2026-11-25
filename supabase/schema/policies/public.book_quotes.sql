-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_quotes Users can manage their own quotes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own quotes" ON "public"."book_quotes" USING (("auth"."uid"() = "user_id"));


--

-- Name: book_quotes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."book_quotes" ENABLE ROW LEVEL SECURITY;

--
