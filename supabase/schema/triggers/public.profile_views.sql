-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profile_views fcm-dispatcher-webhook; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "fcm-dispatcher-webhook" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://lhlylcyuvfpauwvuxped.supabase.co/functions/v1/fcm-dispatcher', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxobHlsY3l1dmZwYXV3dnV4cGVkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjI5NTM0MywiZXhwIjoyMDk3ODcxMzQzfQ.xeN_tjRgZ0PQC0P1udZSyPJtR71q5uv2kywgKv7-fXg"}', '{}', '10000');


--

-- Name: profile_views on_profile_view; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_profile_view" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "public"."handle_profile_view_notification"();


--

-- Name: profile_views tr_fcm_on_profile_view_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_fcm_on_profile_view_insert" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_fcm_notification"();


--

-- Name: profile_views tr_on_profile_view_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_on_profile_view_insert" AFTER INSERT ON "public"."profile_views" FOR EACH ROW EXECUTE FUNCTION "public"."increment_profile_view_count"();


--
