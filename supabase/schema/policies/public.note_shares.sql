-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: note_shares; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."note_shares" ENABLE ROW LEVEL SECURITY;

--

-- Name: note_shares shares_collaborator_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "shares_collaborator_select" ON "public"."note_shares" FOR SELECT USING (("user_id" = "auth"."uid"()));


--

-- Name: note_shares shares_owner_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "shares_owner_all" ON "public"."note_shares" USING ("public"."safe_check_note_owner"("note_id", "auth"."uid"()));


--
