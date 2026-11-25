-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: account_deletions Users can manage their own deletion request; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own deletion request" ON "public"."account_deletions" TO "authenticated" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: account_deletions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."account_deletions" ENABLE ROW LEVEL SECURITY;

--
