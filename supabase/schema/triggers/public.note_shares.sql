-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: note_shares tr_fcm_on_note_share_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_fcm_on_note_share_insert" AFTER INSERT ON "public"."note_shares" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();


--
