-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: secret_vault_items Users can manage their own vault items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own vault items" ON "public"."secret_vault_items" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: secret_vault_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secret_vault_items" ENABLE ROW LEVEL SECURITY;

--
