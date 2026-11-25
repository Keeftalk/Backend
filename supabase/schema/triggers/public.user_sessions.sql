-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_sessions tr_notify_session_revoked; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_notify_session_revoked" AFTER DELETE ON "public"."user_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."notify_session_revoked"();


--
