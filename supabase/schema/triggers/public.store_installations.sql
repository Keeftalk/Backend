-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_installations trg_store_install_stats; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_store_install_stats" AFTER INSERT ON "public"."store_installations" FOR EACH ROW EXECUTE FUNCTION "public"."update_extension_install_stats"();


--
