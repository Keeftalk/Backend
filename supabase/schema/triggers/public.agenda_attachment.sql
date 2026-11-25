-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: agenda_attachment tr_ref_count_agenda; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_ref_count_agenda" AFTER INSERT OR DELETE ON "public"."agenda_attachment" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();


--
