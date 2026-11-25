-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profile_views Users can see views on their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can see views on their own profile" ON "public"."profile_views" FOR SELECT USING ((("auth"."uid"() = "viewed_id") OR ("auth"."uid"() = "viewer_id")));


--
