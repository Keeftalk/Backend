-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_storage_regions Users can read own storage region; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own storage region" ON "public"."user_storage_regions" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--

-- Name: user_storage_regions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_storage_regions" ENABLE ROW LEVEL SECURITY;

--
