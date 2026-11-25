-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_totp_accounts Users can manage their own TOTP accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own TOTP accounts" ON "public"."secret_totp_accounts" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: secret_totp_accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secret_totp_accounts" ENABLE ROW LEVEL SECURITY;

--
