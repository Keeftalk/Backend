-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profile_views Users can record a view; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can record a view" ON "public"."profile_views" FOR INSERT WITH CHECK (("auth"."uid"() = "viewer_id"));


--

-- Name: profile_views Users can record views; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can record views" ON "public"."profile_views" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "viewer_id"));


--

-- Name: profile_views Users can see who viewed them; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can see who viewed them" ON "public"."profile_views" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "viewed_id"));


--

-- Name: profile_views; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profile_views" ENABLE ROW LEVEL SECURITY;

--
