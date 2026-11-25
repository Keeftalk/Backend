-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_item tr_ref_count_vault; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_ref_count_vault" AFTER INSERT OR DELETE ON "public"."vault_item" FOR EACH ROW EXECUTE FUNCTION "public"."update_file_reference_count"();


--
