-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_logs Users can view logs for their shares; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view logs for their shares" ON "public"."vault_share_logs" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."vault_shares"
  WHERE (("vault_shares"."id" = "vault_share_logs"."share_id") AND ("vault_shares"."user_id" = ("auth"."uid"())::"text")))));


--

-- Name: vault_share_logs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_share_logs" ENABLE ROW LEVEL SECURITY;

--
