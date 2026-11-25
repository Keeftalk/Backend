-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_credentials Users can manage their own secret credentials; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own secret credentials" ON "public"."secret_credentials" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: secret_credentials; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secret_credentials" ENABLE ROW LEVEL SECURITY;

--
