-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_doc_settings Users manage their own doc settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own doc settings" ON "public"."user_doc_settings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_doc_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_doc_settings" ENABLE ROW LEVEL SECURITY;

--
