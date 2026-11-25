-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profile_background_media Public can view background media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view background media" ON "public"."profile_background_media" FOR SELECT TO "authenticated" USING (true);


--

-- Name: profile_background_media Users can manage their background media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their background media" ON "public"."profile_background_media" TO "authenticated" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: profile_background_media; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profile_background_media" ENABLE ROW LEVEL SECURITY;

--
