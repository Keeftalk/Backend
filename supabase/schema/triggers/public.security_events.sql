-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: security_events on_security_event; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_security_event" AFTER INSERT ON "public"."security_events" FOR EACH ROW EXECUTE FUNCTION "public"."handle_security_event_notification"();


--

-- Name: security_events tr_notify_security_event; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_notify_security_event" AFTER INSERT ON "public"."security_events" FOR EACH ROW EXECUTE FUNCTION "public"."notify_security_event"();


--
