-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_items Users can manage their vault items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their vault items" ON "public"."vault_items" USING ((("auth"."uid"())::"text" = "user_id")) WITH CHECK ((("auth"."uid"())::"text" = "user_id"));


--

-- Name: vault_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."vault_items" ENABLE ROW LEVEL SECURITY;

--
