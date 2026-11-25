-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_progress Users can manage their own book progress; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own book progress" ON "public"."book_progress" USING (("auth"."uid"() = "user_id"));


--

-- Name: book_progress; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."book_progress" ENABLE ROW LEVEL SECURITY;

--
