-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_settings Parents can update child settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Parents can update child settings" ON "public"."user_settings" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."families" "f"
     JOIN "public"."profiles" "p" ON (("p"."family_id" = "f"."id")))
  WHERE ((("f"."owner_id")::"text" = ("auth"."uid"())::"text") AND (("p"."id")::"text" = ("user_settings"."user_id")::"text"))))) WITH CHECK (true);


--

-- Name: user_settings Parents can view child settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Parents can view child settings" ON "public"."user_settings" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."families" "f"
     JOIN "public"."profiles" "p" ON (("p"."family_id" = "f"."id")))
  WHERE ((("f"."owner_id")::"text" = ("auth"."uid"())::"text") AND (("p"."id")::"text" = ("user_settings"."user_id")::"text")))));


--

-- Name: user_settings Users can delete own settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete own settings" ON "public"."user_settings" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_settings Users can delete their settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their settings" ON "public"."user_settings" FOR DELETE USING (("auth"."uid"() = "user_id"));


--

-- Name: user_settings Users can insert own settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own settings" ON "public"."user_settings" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_settings Users can insert their settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their settings" ON "public"."user_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_settings Users can update own settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own settings" ON "public"."user_settings" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_settings Users can update their settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their settings" ON "public"."user_settings" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK ((("auth"."uid"() = "user_id") AND ((("parental_controls" ->> 'supervisor_id'::"text") IS NULL) OR (("parental_controls" ->> 'supervisor_id'::"text") = ("auth"."uid"())::"text"))));


--

-- Name: user_settings Users can view own settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own settings" ON "public"."user_settings" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_settings" ENABLE ROW LEVEL SECURITY;

--
