-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_submissions Publishers view own submissions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Publishers view own submissions" ON "public"."store_submissions" USING ((EXISTS ( SELECT 1
   FROM "public"."store_publishers" "p"
  WHERE (("p"."id" = "store_submissions"."publisher_id") AND ("p"."user_id" = "auth"."uid"())))));


--

-- Name: store_submissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_submissions" ENABLE ROW LEVEL SECURITY;

--
