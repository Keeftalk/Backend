-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_folders Users can manage own vault folders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage own vault folders" ON "public"."vault_folders" USING (("auth"."uid"() = "user_id"));


--

-- Name: vault_folders Users can manage their own folders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own folders" ON "public"."vault_folders" USING (("auth"."uid"() = "user_id"));


--

-- Name: vault_folders Users can manage their vault folders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their vault folders" ON "public"."vault_folders" USING ((("auth"."uid"())::"text" = ("user_id")::"text")) WITH CHECK ((("auth"."uid"())::"text" = ("user_id")::"text"));


--

-- Name: vault_folders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_folders" ENABLE ROW LEVEL SECURITY;

--
