-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_docs Users manage their own documents; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own documents" ON "public"."user_docs" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_docs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_docs" ENABLE ROW LEVEL SECURITY;

--
