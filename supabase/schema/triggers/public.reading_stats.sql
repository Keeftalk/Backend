-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: reading_stats update_reading_stats_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_reading_stats_updated_at" BEFORE UPDATE ON "public"."reading_stats" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
