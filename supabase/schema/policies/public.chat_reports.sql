-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_reports Users can report chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can report chats" ON "public"."chat_reports" FOR INSERT WITH CHECK ((("reporter_id")::"text" = ("auth"."uid"())::"text"));


--

-- Name: chat_reports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."chat_reports" ENABLE ROW LEVEL SECURITY;

--
