-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: relationship_intelligence Users can view their own relationship scores; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own relationship scores" ON "public"."relationship_intelligence" FOR SELECT USING ((("auth"."uid"() = "user_a") OR ("auth"."uid"() = "user_b")));


--

-- Name: relationship_intelligence; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."relationship_intelligence" ENABLE ROW LEVEL SECURITY;

--
