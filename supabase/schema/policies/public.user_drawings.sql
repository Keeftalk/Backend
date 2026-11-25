-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_drawings Users manage their own drawings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage their own drawings" ON "public"."user_drawings" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_drawings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_drawings" ENABLE ROW LEVEL SECURITY;

--
