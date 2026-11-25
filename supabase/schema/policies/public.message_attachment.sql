-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_attachment Chat members can view attachments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Chat members can view attachments" ON "public"."message_attachment" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."messages" "m"
     JOIN "public"."chat_members" "cm" ON ((("m"."chat_id")::"text" = ("cm"."chat_id")::"text")))
  WHERE ((("m"."id")::"text" = ("message_attachment"."message_id")::"text") AND (("cm"."user_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: message_attachment Users can insert attachments for their messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert attachments for their messages" ON "public"."message_attachment" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."messages" "m"
  WHERE ((("m"."id")::"text" = ("message_attachment"."message_id")::"text") AND (("m"."sender_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: message_attachment Users can manage their own message attachments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own message attachments" ON "public"."message_attachment" USING ((EXISTS ( SELECT 1
   FROM "public"."messages"
  WHERE (("messages"."id" = "message_attachment"."message_id") AND ("messages"."sender_id" = "auth"."uid"())))));


--

-- Name: message_attachment; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_attachment" ENABLE ROW LEVEL SECURITY;

--
