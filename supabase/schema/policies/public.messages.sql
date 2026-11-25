-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: messages Admins can read all messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read all messages" ON "public"."messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admin_users"
  WHERE ("admin_users"."id" = "auth"."uid"()))));


--

-- Name: messages Users can insert messages into their chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert messages into their chats" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_chat_member"("chat_id") AND ((("auth"."uid"())::"text" = ("sender_id")::"text") OR (("sender_id")::"text" = 'ai'::"text"))));


--

-- Name: messages Users can update status of received messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update status of received messages" ON "public"."messages" FOR UPDATE USING (("auth"."uid"() <> "sender_id")) WITH CHECK (("status" = ANY (ARRAY['DELIVERED'::"text", 'SEEN'::"text"])));


--

-- Name: messages Users can update their own messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own messages" ON "public"."messages" FOR UPDATE TO "authenticated" USING (((("sender_id")::"text" = ("auth"."uid"())::"text") OR ((("sender_id")::"text" = 'ai'::"text") AND "public"."is_chat_member"("chat_id")))) WITH CHECK (((("sender_id")::"text" = ("auth"."uid"())::"text") OR ((("sender_id")::"text" = 'ai'::"text") AND "public"."is_chat_member"("chat_id"))));


--

-- Name: messages Users can view messages in their chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view messages in their chats" ON "public"."messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE (("chat_members"."chat_id" = "messages"."chat_id") AND ("chat_members"."user_id" = "auth"."uid"())))));


--

-- Name: messages members can update message status; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members can update message status" ON "public"."messages" FOR UPDATE USING ("public"."is_chat_member"("chat_id")) WITH CHECK ("public"."is_chat_member"("chat_id"));


--

-- Name: messages members insert messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members insert messages" ON "public"."messages" FOR INSERT WITH CHECK ("public"."is_chat_member"("chat_id"));


--

-- Name: messages members update message status; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members update message status" ON "public"."messages" FOR UPDATE USING ("public"."is_chat_member"("chat_id")) WITH CHECK ("public"."is_chat_member"("chat_id"));


--

-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

--

-- Name: messages messages_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "messages_insert" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_member_of"("chat_id"));


--

-- Name: messages messages_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "messages_select" ON "public"."messages" FOR SELECT TO "authenticated" USING ("public"."is_member_of"("chat_id"));


--

-- Name: messages messages_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "messages_update" ON "public"."messages" FOR UPDATE USING (("sender_id" = "auth"."uid"()));


--

-- Name: messages verified members read messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "verified members read messages" ON "public"."messages" FOR SELECT USING (("public"."is_email_verified"() AND "public"."is_chat_member"("chat_id")));


--
