-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_visibility Users can manage their own message visibility; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own message visibility" ON "public"."message_visibility" TO "authenticated" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: message_visibility; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_visibility" ENABLE ROW LEVEL SECURITY;

--
