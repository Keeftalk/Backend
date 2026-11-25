-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: vault_share_imports tr_vault_import_started; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_vault_import_started" AFTER INSERT ON "public"."vault_share_imports" FOR EACH ROW EXECUTE FUNCTION "public"."on_vault_import_started"();


--
