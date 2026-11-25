-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: system_metrics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."system_metrics" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."system_metrics_id_seq"'::"regclass");


--
