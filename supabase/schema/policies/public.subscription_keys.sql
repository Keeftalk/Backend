-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: subscription_keys Admins can manage keys; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage keys" ON "public"."subscription_keys" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));


--

-- Name: subscription_keys; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."subscription_keys" ENABLE ROW LEVEL SECURITY;

--
