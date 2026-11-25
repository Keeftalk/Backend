-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: data_exports Users can insert their own data exports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own data exports" ON "public"."data_exports" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: data_exports Users can view their own data exports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own data exports" ON "public"."data_exports" FOR SELECT TO "authenticated" USING ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: data_exports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."data_exports" ENABLE ROW LEVEL SECURITY;

--
