-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_members Admins can add members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can add members" ON "public"."chat_members" FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."chat_members" "chat_members_1"
  WHERE (("chat_members_1"."chat_id" = "chat_members_1"."chat_id") AND ("chat_members_1"."user_id" = "auth"."uid"()) AND ("chat_members_1"."role" = 'admin'::"text")))) OR ("auth"."uid"() = "user_id")));


--

-- Name: chat_members Users can join chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can join chats" ON "public"."chat_members" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: chat_members Users can leave groups; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can leave groups" ON "public"."chat_members" FOR DELETE USING (("auth"."uid"() = "user_id"));


--

-- Name: chat_members Users can update their own chat membership; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own chat membership" ON "public"."chat_members" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: chat_members Users can update their own member settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own member settings" ON "public"."chat_members" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--

-- Name: chat_members; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."chat_members" ENABLE ROW LEVEL SECURITY;

--

-- Name: chat_members chat_members_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "chat_members_insert" ON "public"."chat_members" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));


--

-- Name: chat_members members can see chat members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members can see chat members" ON "public"."chat_members" FOR SELECT USING ("public"."is_chat_member"("chat_id"));


--

-- Name: chat_members members_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members_admin" ON "public"."chat_members" TO "authenticated" USING ("public"."is_admin_of"("chat_id"));


--

-- Name: chat_members members_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members_insert" ON "public"."chat_members" FOR INSERT TO "authenticated" WITH CHECK (true);


--

-- Name: chat_members members_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members_select" ON "public"."chat_members" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR "public"."is_member_of"("chat_id")));


--
