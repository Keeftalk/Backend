-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: feature_sync_plans feature_sync_plans_feature_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."feature_sync_plans"
    ADD CONSTRAINT "feature_sync_plans_feature_id_key" UNIQUE ("feature_id");


--

-- Name: feature_sync_plans feature_sync_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."feature_sync_plans"
    ADD CONSTRAINT "feature_sync_plans_pkey" PRIMARY KEY ("id");


--
