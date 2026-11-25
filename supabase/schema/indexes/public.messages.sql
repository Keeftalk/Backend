-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--

-- Name: idx_messages_chat_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_messages_chat_created" ON "public"."messages" USING "btree" ("chat_id", "created_at" DESC);


--

-- Name: idx_messages_chat_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_messages_chat_id_created_at" ON "public"."messages" USING "btree" ("chat_id", "created_at" DESC);


--

-- Name: idx_messages_chat_id_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_messages_chat_id_timestamp" ON "public"."messages" USING "btree" ("chat_id", "timestamp" DESC);


--

-- Name: idx_messages_chat_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_messages_chat_timestamp" ON "public"."messages" USING "btree" ("chat_id", "timestamp");


--

-- Name: idx_messages_media_lock; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_messages_media_lock" ON "public"."messages" USING "btree" ("media_locked");


--

-- Name: idx_messages_reply_to_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_messages_reply_to_id" ON "public"."messages" USING "btree" ("reply_to_id");


--

-- Name: messages messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;


--

-- Name: messages messages_media_lock_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_media_lock_updated_by_fkey" FOREIGN KEY ("media_lock_updated_by") REFERENCES "auth"."users"("id");


--

-- Name: messages messages_reply_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_reply_to_id_fkey" FOREIGN KEY ("reply_to_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;


--

-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
