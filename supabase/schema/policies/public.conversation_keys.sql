-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: conversation_keys Chat members can read conversation keys; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Chat members can read conversation keys" ON "public"."conversation_keys" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = "conversation_keys"."conversation_id") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: conversation_keys Users can insert keys for chats they are in; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert keys for chats they are in" ON "public"."conversation_keys" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = "conversation_keys"."conversation_id") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: conversation_keys Users can manage their own conversation keys; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own conversation keys" ON "public"."conversation_keys" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: conversation_keys; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."conversation_keys" ENABLE ROW LEVEL SECURITY;

--
