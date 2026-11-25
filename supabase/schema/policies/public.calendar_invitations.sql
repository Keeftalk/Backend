-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: calendar_invitations Receivers can update invitation status; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Receivers can update invitation status" ON "public"."calendar_invitations" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "to_user_id")) WITH CHECK (("auth"."uid"() = "to_user_id"));


--

-- Name: calendar_invitations Users can send invitations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can send invitations" ON "public"."calendar_invitations" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "from_user_id"));


--

-- Name: calendar_invitations Users can view their own sent/received invitations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own sent/received invitations" ON "public"."calendar_invitations" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "from_user_id") OR ("auth"."uid"() = "to_user_id")));


--

-- Name: calendar_invitations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."calendar_invitations" ENABLE ROW LEVEL SECURITY;

--

-- Name: calendar_invitations calendar_invitations_access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "calendar_invitations_access" ON "public"."calendar_invitations" USING ((("from_user_id" = "auth"."uid"()) OR ("to_user_id" = "auth"."uid"())));


--
