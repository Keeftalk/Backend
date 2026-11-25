-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_visibility on_visibility_updated; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_visibility_updated" BEFORE UPDATE ON "public"."message_visibility" FOR EACH ROW EXECUTE FUNCTION "public"."handle_visibility_updated_at"();


--
