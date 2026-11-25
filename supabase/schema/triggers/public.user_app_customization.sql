-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_app_customization on_user_app_customization_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_user_app_customization_update" BEFORE UPDATE ON "public"."user_app_customization" FOR EACH ROW EXECUTE FUNCTION "public"."handle_app_customization_updated_at"();


--

-- Name: user_app_customization set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "set_updated_at" BEFORE UPDATE ON "public"."user_app_customization" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();


--
