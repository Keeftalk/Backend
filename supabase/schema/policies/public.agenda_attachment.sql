-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: agenda_attachment Users can manage their own agenda attachments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own agenda attachments" ON "public"."agenda_attachment" USING ((EXISTS ( SELECT 1
   FROM "public"."calendar_items"
  WHERE (("calendar_items"."id" = "agenda_attachment"."agenda_event_id") AND ("calendar_items"."owner_id" = "auth"."uid"())))));


--

-- Name: agenda_attachment; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."agenda_attachment" ENABLE ROW LEVEL SECURITY;

--
