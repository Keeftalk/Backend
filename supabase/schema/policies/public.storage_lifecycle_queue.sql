-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: storage_lifecycle_queue Lifecycle queue is backend only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Lifecycle queue is backend only" ON "public"."storage_lifecycle_queue" TO "service_role" USING (true);


--

-- Name: storage_lifecycle_queue; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."storage_lifecycle_queue" ENABLE ROW LEVEL SECURITY;

--
