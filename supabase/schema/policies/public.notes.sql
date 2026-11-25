-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: notes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."notes" ENABLE ROW LEVEL SECURITY;

--

-- Name: notes notes_owner_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "notes_owner_all" ON "public"."notes" USING (("auth"."uid"() = "owner_id"));


--

-- Name: notes notes_select_shared; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "notes_select_shared" ON "public"."notes" FOR SELECT TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "owner_id") OR ("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE ("note_shares"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))));


--

-- Name: notes notes_shared_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "notes_shared_select" ON "public"."notes" FOR SELECT USING (("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE ("note_shares"."user_id" = "auth"."uid"()))));


--

-- Name: notes notes_update_shared; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "notes_update_shared" ON "public"."notes" FOR UPDATE TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "owner_id") OR ("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE (("note_shares"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("note_shares"."access" = 'write'::"text")))))) WITH CHECK (((( SELECT "auth"."uid"() AS "uid") = "owner_id") OR ("id" IN ( SELECT "note_shares"."note_id"
   FROM "public"."note_shares"
  WHERE (("note_shares"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("note_shares"."access" = 'write'::"text"))))));


--
