-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profile_background_media trigger_validate_background_media; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_validate_background_media" BEFORE INSERT OR UPDATE ON "public"."profile_background_media" FOR EACH ROW EXECUTE FUNCTION "public"."validate_background_media"();


--
