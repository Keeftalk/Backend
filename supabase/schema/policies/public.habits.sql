-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habits Users manage own Keeftalk habits; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage own Keeftalk habits" ON "public"."habits" TO "authenticated" USING (("owner_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("owner_id" = ( SELECT "auth"."uid"() AS "uid")));


--

-- Name: habits; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."habits" ENABLE ROW LEVEL SECURITY;

--
