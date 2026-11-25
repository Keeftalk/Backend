-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_password_history Users can manage their own password history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own password history" ON "public"."secret_password_history" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: secret_password_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secret_password_history" ENABLE ROW LEVEL SECURITY;

--
