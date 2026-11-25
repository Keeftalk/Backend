-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_logs Users can manage their own call logs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own call logs" ON "public"."call_logs" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--

-- Name: call_logs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."call_logs" ENABLE ROW LEVEL SECURITY;

--
