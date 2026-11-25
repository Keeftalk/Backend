-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_backup_codes Users can manage their own backup codes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own backup codes" ON "public"."secret_backup_codes" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: secret_backup_codes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secret_backup_codes" ENABLE ROW LEVEL SECURITY;

--
