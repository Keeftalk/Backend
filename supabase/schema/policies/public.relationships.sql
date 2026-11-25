-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: relationships Users can manage their own relationships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own relationships" ON "public"."relationships" USING ((("user_id")::"text" = ("auth"."uid"())::"text"));


--

-- Name: relationships; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."relationships" ENABLE ROW LEVEL SECURITY;

--
