-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_spam_reporters Internal Access Only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Internal Access Only" ON "public"."caller_spam_reporters" USING (false);


--

-- Name: caller_spam_reporters; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."caller_spam_reporters" ENABLE ROW LEVEL SECURITY;

--
