-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: messages fcm-dispatcher-webhook; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');


--

-- Name: messages fcmmsg; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "fcmmsg" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '5000');


--

-- Name: messages on_message_inserted; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_message_inserted" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_message"();


--

-- Name: messages on_message_inserted_sync_chat; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_message_inserted_sync_chat" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_message_sync"();


--

-- Name: messages on_message_sent; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_message_sent" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/smart-task', 'POST', '{"Content-Type":"application/json", "Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}');


--

-- Name: messages tr_fcm_on_message_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_fcm_on_message_insert" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();


--

-- Name: messages tr_message_sent_update_strength; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_message_sent_update_strength" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."on_message_update_relationship_strength"();


--

-- Name: messages tr_official_broadcast_sync; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_official_broadcast_sync" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."on_official_message_sent"();


--

-- Name: messages tr_on_new_message; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_on_new_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."notify_new_message"();


--

-- Name: messages tr_sync_chat_last_message; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_sync_chat_last_message" AFTER INSERT OR UPDATE OF "status" ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."sync_chat_last_message"();


--

-- Name: messages tr_update_chat_on_message; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_update_chat_on_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."handle_message_sync_update"();


--

-- Name: messages trigger_update_chat_last_activity; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_update_chat_last_activity" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_chat_last_activity"();


--
