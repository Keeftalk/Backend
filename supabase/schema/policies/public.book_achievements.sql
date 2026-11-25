-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_achievements Users can manage their own book achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own book achievements" ON "public"."book_achievements" USING (("auth"."uid"() = "user_id"));


--

-- Name: book_achievements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."book_achievements" ENABLE ROW LEVEL SECURITY;

--
