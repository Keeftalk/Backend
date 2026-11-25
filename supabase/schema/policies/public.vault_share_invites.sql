-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_invites Users can manage their own vault share invites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own vault share invites" ON "public"."vault_share_invites" USING (("auth"."uid"() = "sender_id")) WITH CHECK (("auth"."uid"() = "sender_id"));


--

-- Name: vault_share_invites Users can view invites shared with them; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view invites shared with them" ON "public"."vault_share_invites" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vault_share_imports"
  WHERE (("vault_share_imports"."share_id" = "vault_share_invites"."id") AND ("vault_share_imports"."recipient_id" = "auth"."uid"())))));


--

-- Name: vault_share_invites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_share_invites" ENABLE ROW LEVEL SECURITY;

--
