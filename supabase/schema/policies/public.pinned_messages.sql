-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: pinned_messages Chat members can pin messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Chat members can pin messages" ON "public"."pinned_messages" USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = ("pinned_messages"."chat_id")::"text") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: pinned_messages Chat members can view pinned messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Chat members can view pinned messages" ON "public"."pinned_messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."chat_members"
  WHERE ((("chat_members"."chat_id")::"text" = ("pinned_messages"."chat_id")::"text") AND (("chat_members"."user_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: pinned_messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."pinned_messages" ENABLE ROW LEVEL SECURITY;

--
