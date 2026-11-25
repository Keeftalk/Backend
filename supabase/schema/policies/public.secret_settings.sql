-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_settings Users can manage their own secret settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own secret settings" ON "public"."secret_settings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: secret_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secret_settings" ENABLE ROW LEVEL SECURITY;

--
