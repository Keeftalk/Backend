-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listings update_market_listings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_market_listings_updated_at" BEFORE UPDATE ON "public"."market_listings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
