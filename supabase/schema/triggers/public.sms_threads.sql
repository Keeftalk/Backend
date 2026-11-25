-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: sms_threads on_sms_threads_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_sms_threads_update" BEFORE UPDATE ON "public"."sms_threads" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();


--
