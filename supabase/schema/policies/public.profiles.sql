-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profiles Profiles are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Profiles are viewable by everyone." ON "public"."profiles" FOR SELECT USING (true);


--

-- Name: profiles Public profiles are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public profiles are viewable by everyone" ON "public"."profiles" FOR SELECT USING (true);


--

-- Name: profiles Public profiles read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public profiles read" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--

-- Name: profiles Users can insert own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own profile" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."uid"())::"text" = ("id")::"text"));


--

-- Name: profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));


--

-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING ((("auth"."uid"())::"text" = ("id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("id")::"text"));


--

-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));


--

-- Name: profiles Users can view profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--

-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--

-- Name: profiles update own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));


--

-- Name: profiles users can insert own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "users can insert own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));


--

-- Name: profiles verified users can read profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "verified users can read profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--
