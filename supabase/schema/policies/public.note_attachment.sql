-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: note_attachment Users can manage their own note attachments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own note attachments" ON "public"."note_attachment" USING ((EXISTS ( SELECT 1
   FROM "public"."notes"
  WHERE (("notes"."id" = "note_attachment"."note_id") AND ("notes"."owner_id" = "auth"."uid"())))));


--

-- Name: note_attachment; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."note_attachment" ENABLE ROW LEVEL SECURITY;

--
