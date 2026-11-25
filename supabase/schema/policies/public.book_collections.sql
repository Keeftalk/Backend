-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_collections Users can manage their own collections; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own collections" ON "public"."book_collections" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: book_collections; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."book_collections" ENABLE ROW LEVEL SECURITY;

--
