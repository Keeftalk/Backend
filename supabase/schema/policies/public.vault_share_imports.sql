-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_imports Recipients can view their own imports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Recipients can view their own imports" ON "public"."vault_share_imports" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "recipient_id"));


--

-- Name: vault_share_imports Senders can view imports of their shares; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Senders can view imports of their shares" ON "public"."vault_share_imports" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vault_share_invites"
  WHERE (("vault_share_invites"."id" = "vault_share_imports"."share_id") AND ("vault_share_invites"."sender_id" = "auth"."uid"())))));


--

-- Name: vault_share_imports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_share_imports" ENABLE ROW LEVEL SECURITY;

--
