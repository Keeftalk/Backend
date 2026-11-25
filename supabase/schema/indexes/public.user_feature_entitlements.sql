-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: user_feature_entitlements user_feature_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_feature_entitlements"
    ADD CONSTRAINT "user_feature_entitlements_pkey" PRIMARY KEY ("id");


--

-- Name: idx_user_feature_entitlements_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_feature_entitlements_user_id" ON "public"."user_feature_entitlements" USING "btree" ("user_id");


--
