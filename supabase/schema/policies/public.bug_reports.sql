-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: bug_reports Users can insert their own reports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own reports" ON "public"."bug_reports" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: bug_reports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."bug_reports" ENABLE ROW LEVEL SECURITY;

--
