-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: message_reactions fcm-dispatcher-webhook; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."message_reactions" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');


--

-- Name: message_reactions tr_fcm_on_reaction_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_fcm_on_reaction_insert" AFTER INSERT ON "public"."message_reactions" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();


--
