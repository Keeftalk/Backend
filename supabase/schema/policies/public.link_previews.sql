-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: link_previews Allow public read of link previews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read of link previews" ON "public"."link_previews" FOR SELECT USING (true);


--

-- Name: link_previews Allow service role to manage previews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow service role to manage previews" ON "public"."link_previews" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));


--

-- Name: link_previews; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."link_previews" ENABLE ROW LEVEL SECURITY;

--
