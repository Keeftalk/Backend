-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: contacts Users can delete own contacts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete own contacts" ON "public"."contacts" FOR DELETE USING (("auth"."uid"() = "owner_id"));


--

-- Name: contacts Users can insert own contacts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own contacts" ON "public"."contacts" FOR INSERT WITH CHECK (("auth"."uid"() = "owner_id"));


--

-- Name: contacts Users can manage their own contacts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own contacts" ON "public"."contacts" TO "authenticated" USING (("auth"."uid"() = "owner_id")) WITH CHECK (("auth"."uid"() = "owner_id"));


--

-- Name: contacts Users can update own contacts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own contacts" ON "public"."contacts" FOR UPDATE USING (("auth"."uid"() = "owner_id"));


--

-- Name: contacts Users can view own contacts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own contacts" ON "public"."contacts" FOR SELECT USING (("auth"."uid"() = "owner_id"));


--

-- Name: contacts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."contacts" ENABLE ROW LEVEL SECURITY;

--
