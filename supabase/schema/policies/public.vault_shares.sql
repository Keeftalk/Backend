-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_shares Users can manage their own vault shares; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own vault shares" ON "public"."vault_shares" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: vault_shares; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_shares" ENABLE ROW LEVEL SECURITY;

--
