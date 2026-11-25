-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_members tr_sync_chat_status_from_pointers; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_sync_chat_status_from_pointers" AFTER UPDATE OF "last_read_message_id", "last_delivered_message_id" ON "public"."chat_members" FOR EACH ROW EXECUTE FUNCTION "public"."sync_chat_status_from_pointers"();


--
