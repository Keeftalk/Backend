-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_reactions members can read reactions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members can read reactions" ON "public"."message_reactions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."messages" "m"
  WHERE (("m"."id" = "message_reactions"."message_id") AND "public"."is_chat_member"("m"."chat_id")))));


--

-- Name: message_reactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_reactions" ENABLE ROW LEVEL SECURITY;

--

-- Name: message_reactions reactions_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "reactions_insert" ON "public"."message_reactions" FOR INSERT TO "authenticated" WITH CHECK (true);


--

-- Name: message_reactions reactions_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "reactions_select" ON "public"."message_reactions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."messages"
  WHERE (("messages"."id" = "message_reactions"."message_id") AND "public"."is_member_of"("messages"."chat_id")))));


--

-- Name: message_reactions users can manage own reactions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users can manage own reactions" ON "public"."message_reactions" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--
