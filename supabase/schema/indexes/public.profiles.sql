-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--

-- Name: profiles profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");


--

-- Name: idx_profiles_fcm_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_profiles_fcm_token" ON "public"."profiles" USING "btree" ("fcm_token") WHERE ("fcm_token" IS NOT NULL);


--

-- Name: idx_profiles_last_seen; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_profiles_last_seen" ON "public"."profiles" USING "btree" ("last_seen");


--

-- Name: idx_profiles_total_xp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_profiles_total_xp" ON "public"."profiles" USING "btree" ("total_xp" DESC);


--

-- Name: profiles_full_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "profiles_full_name_idx" ON "public"."profiles" USING "gin" ("full_name" "public"."gin_trgm_ops");


--

-- Name: profiles_username_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "profiles_username_idx" ON "public"."profiles" USING "gin" ("username" "public"."gin_trgm_ops");


--

-- Name: profiles profiles_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_family_id_fkey" FOREIGN KEY ("family_id") REFERENCES "public"."families"("id") ON DELETE SET NULL;


--

-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
