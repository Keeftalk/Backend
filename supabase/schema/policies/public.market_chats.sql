-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_chats Participants can insert market_chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Participants can insert market_chats" ON "public"."market_chats" FOR INSERT WITH CHECK (((("auth"."uid"())::"text" = ("buyer_id")::"text") OR (("auth"."uid"())::"text" = ("seller_id")::"text")));


--

-- Name: market_chats Participants can update market_chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Participants can update market_chats" ON "public"."market_chats" FOR UPDATE USING (((("auth"."uid"())::"text" = ("buyer_id")::"text") OR (("auth"."uid"())::"text" = ("seller_id")::"text")));


--

-- Name: market_chats Participants can view market_chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Participants can view market_chats" ON "public"."market_chats" FOR SELECT USING (((("auth"."uid"())::"text" = ("buyer_id")::"text") OR (("auth"."uid"())::"text" = ("seller_id")::"text")));


--

-- Name: market_chats; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."market_chats" ENABLE ROW LEVEL SECURITY;

--
