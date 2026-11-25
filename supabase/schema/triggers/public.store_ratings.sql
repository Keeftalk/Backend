-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: store_ratings trg_store_rating_stats; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trg_store_rating_stats" AFTER INSERT OR DELETE OR UPDATE ON "public"."store_ratings" FOR EACH ROW EXECUTE FUNCTION "public"."update_extension_rating_stats"();


--
