-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_item Users can manage their own vault items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own vault items" ON "public"."vault_item" USING (("auth"."uid"() = "user_id"));


--

-- Name: vault_item Users can manage their vault items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their vault items" ON "public"."vault_item" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: vault_item; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_item" ENABLE ROW LEVEL SECURITY;

--
