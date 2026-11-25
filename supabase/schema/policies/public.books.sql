-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: books Users can manage their own books; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own books" ON "public"."books" USING (("auth"."uid"() = "user_id"));


--

-- Name: books; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."books" ENABLE ROW LEVEL SECURITY;

--
