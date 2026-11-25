-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_link_previews Allow read of message link previews for participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow read of message link previews for participants" ON "public"."message_link_previews" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."messages" "m"
     JOIN "public"."chat_members" "cm" ON (("m"."chat_id" = "cm"."chat_id")))
  WHERE (("m"."id" = "message_link_previews"."message_id") AND ("cm"."user_id" = "auth"."uid"())))));


--

-- Name: message_link_previews Allow service role to manage all associations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow service role to manage all associations" ON "public"."message_link_previews" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));


--

-- Name: message_link_previews Allow service role to manage message associations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow service role to manage message associations" ON "public"."message_link_previews" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));


--

-- Name: message_link_previews Allow users to insert their own message link previews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow users to insert their own message link previews" ON "public"."message_link_previews" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."messages"
  WHERE (("messages"."id" = "message_link_previews"."message_id") AND ("messages"."sender_id" = "auth"."uid"())))));


--

-- Name: message_link_previews; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_link_previews" ENABLE ROW LEVEL SECURITY;

--
