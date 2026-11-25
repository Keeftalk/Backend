-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: files Owners can manage their files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Owners can manage their files" ON "public"."files" USING ((("auth"."uid"())::"text" = ("owner_id")::"text"));


--

-- Name: files Recipients can update metadata for referenced files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Recipients can update metadata for referenced files" ON "public"."files" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM (("public"."message_attachment" "ma"
     JOIN "public"."messages" "m" ON ((("ma"."message_id")::"text" = ("m"."id")::"text")))
     JOIN "public"."chat_members" "cm" ON ((("m"."chat_id")::"text" = ("cm"."chat_id")::"text")))
  WHERE ((("ma"."file_id")::"text" = ("files"."id")::"text") AND (("cm"."user_id")::"text" = ("auth"."uid"())::"text"))))) WITH CHECK (true);


--

-- Name: files Recipients can view referenced files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Recipients can view referenced files" ON "public"."files" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (("public"."message_attachment" "ma"
     JOIN "public"."messages" "m" ON ((("ma"."message_id")::"text" = ("m"."id")::"text")))
     JOIN "public"."chat_members" "cm" ON ((("m"."chat_id")::"text" = ("cm"."chat_id")::"text")))
  WHERE ((("ma"."file_id")::"text" = ("files"."id")::"text") AND (("cm"."user_id")::"text" = ("auth"."uid"())::"text")))));


--

-- Name: files Users can manage their own files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own files" ON "public"."files" USING (("auth"."uid"() = "owner_id"));


--

-- Name: files Vault users can view referenced files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Vault users can view referenced files" ON "public"."files" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vault_items" "vi"
  WHERE (("vi"."file_id" = "files"."id") AND ("vi"."user_id" = ("auth"."uid"())::"text")))));


--

-- Name: files View accessible files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "View accessible files" ON "public"."files" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "owner_id") OR (EXISTS ( SELECT 1
   FROM ("public"."message_attachment" "ma"
     JOIN "public"."messages" "m" ON (("ma"."message_id" = "m"."id")))
  WHERE (("ma"."file_id" = "files"."id") AND (("m"."sender_id" = "auth"."uid"()) OR ("m"."chat_id" IN ( SELECT "chat_members"."chat_id"
           FROM "public"."chat_members"
          WHERE ("chat_members"."user_id" = "auth"."uid"()))))))) OR (EXISTS ( SELECT 1
   FROM ("public"."note_attachment" "na"
     JOIN "public"."notes" "n" ON (("na"."note_id" = "n"."id")))
  WHERE (("na"."file_id" = "files"."id") AND (("n"."owner_id" = "auth"."uid"()) OR ("n"."id" IN ( SELECT "note_shares"."note_id"
           FROM "public"."note_shares"
          WHERE ("note_shares"."user_id" = "auth"."uid"()))))))) OR (EXISTS ( SELECT 1
   FROM ("public"."agenda_attachment" "aa"
     JOIN "public"."calendar_items" "ci" ON (("aa"."agenda_event_id" = "ci"."id")))
  WHERE (("aa"."file_id" = "files"."id") AND ("ci"."owner_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."vault_item" "vi"
  WHERE (("vi"."file_id" = "files"."id") AND ("vi"."user_id" = "auth"."uid"()))))));


--

-- Name: files; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."files" ENABLE ROW LEVEL SECURITY;

--
