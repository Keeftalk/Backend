-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_attachment tr_ref_count_chat; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_ref_count_chat" AFTER INSERT OR DELETE ON "public"."message_attachment" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();


--
