-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_time_tracking Users can manage their own time tracking; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own time tracking" ON "public"."user_time_tracking" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: user_time_tracking; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_time_tracking" ENABLE ROW LEVEL SECURITY;

--
