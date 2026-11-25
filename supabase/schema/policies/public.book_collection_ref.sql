-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_collection_ref Users can manage their own collection refs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own collection refs" ON "public"."book_collection_ref" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: book_collection_ref; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."book_collection_ref" ENABLE ROW LEVEL SECURITY;

--
