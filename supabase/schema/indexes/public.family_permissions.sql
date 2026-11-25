-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: family_permissions family_permissions_family_member_id_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."family_permissions"
    ADD CONSTRAINT "family_permissions_family_member_id_type_key" UNIQUE ("family_member_id", "type");


--

-- Name: family_permissions family_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."family_permissions"
    ADD CONSTRAINT "family_permissions_pkey" PRIMARY KEY ("id");


--
