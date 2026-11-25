-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: billing_pricing billing_pricing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_pricing"
    ADD CONSTRAINT "billing_pricing_pkey" PRIMARY KEY ("id");


--

-- Name: billing_pricing billing_pricing_version_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."billing_pricing"
    ADD CONSTRAINT "billing_pricing_version_name_key" UNIQUE ("version_name");


--
