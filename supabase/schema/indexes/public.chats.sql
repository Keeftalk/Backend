-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chats"
    ADD CONSTRAINT "chats_pkey" PRIMARY KEY ("id");


--

-- Name: idx_chats_last_activity_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chats_last_activity_at" ON "public"."chats" USING "btree" ("last_activity_at" DESC);


--

-- Name: idx_chats_last_message_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chats_last_message_time" ON "public"."chats" USING "btree" ("last_message_time_ms" DESC);


--
