-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chats Users can create their own chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create their own chats" ON "public"."chats" FOR INSERT TO "authenticated" WITH CHECK (true);


--

-- Name: chats chat members can update chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "chat members can update chats" ON "public"."chats" FOR UPDATE USING ("public"."is_chat_member"("id"));


--

-- Name: chats; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."chats" ENABLE ROW LEVEL SECURITY;

--

-- Name: chats chats_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "chats_insert" ON "public"."chats" FOR INSERT TO "authenticated" WITH CHECK (true);


--

-- Name: chats chats_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "chats_select" ON "public"."chats" FOR SELECT TO "authenticated" USING ("public"."is_member_of"("id"));


--

-- Name: chats chats_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "chats_update" ON "public"."chats" FOR UPDATE TO "authenticated" USING ("public"."is_admin_of"("id"));


--

-- Name: chats members can update chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "members can update chats" ON "public"."chats" FOR UPDATE USING ("public"."is_chat_member"("id"));


--

-- Name: chats verified members can read chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "verified members can read chats" ON "public"."chats" FOR SELECT USING (("public"."is_email_verified"() AND "public"."is_chat_member"("id")));


--
