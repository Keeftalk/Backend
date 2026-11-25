-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_extensions Public read published extensions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read published extensions" ON "public"."store_extensions" FOR SELECT USING (true);


--

-- Name: store_extensions Publishers insert own extensions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Publishers insert own extensions" ON "public"."store_extensions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."store_publishers" "p"
  WHERE (("p"."id" = "store_extensions"."publisher_id") AND ("p"."user_id" = "auth"."uid"())))));


--

-- Name: store_extensions Publishers update own draft extensions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Publishers update own draft extensions" ON "public"."store_extensions" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."store_publishers" "p"
  WHERE (("p"."id" = "store_extensions"."publisher_id") AND ("p"."user_id" = "auth"."uid"())))));


--

-- Name: store_extensions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."store_extensions" ENABLE ROW LEVEL SECURITY;

--
