-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_chat_settings update_user_chat_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_user_chat_settings_updated_at" BEFORE UPDATE ON "public"."user_chat_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
