-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: usage_sessions usage_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."usage_sessions"
    ADD CONSTRAINT "usage_sessions_pkey" PRIMARY KEY ("session_id");


--

-- Name: idx_usage_sessions_started_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_usage_sessions_started_at" ON "public"."usage_sessions" USING "btree" ("started_at");


--

-- Name: idx_usage_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_usage_sessions_user_id" ON "public"."usage_sessions" USING "btree" ("user_id");


--

-- Name: usage_sessions usage_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."usage_sessions"
    ADD CONSTRAINT "usage_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
