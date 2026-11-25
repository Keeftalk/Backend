-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_containers Users can manage their own containers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own containers" ON "public"."chat_containers" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: chat_containers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."chat_containers" ENABLE ROW LEVEL SECURITY;

--
