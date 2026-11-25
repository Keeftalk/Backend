-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_members chat_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_pkey" PRIMARY KEY ("chat_id", "user_id");


--

-- Name: chat_members_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "chat_members_user_id_idx" ON "public"."chat_members" USING "btree" ("user_id");


--

-- Name: idx_chat_members_last_delivered; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chat_members_last_delivered" ON "public"."chat_members" USING "btree" ("last_delivered_message_id");


--

-- Name: idx_chat_members_last_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chat_members_last_read" ON "public"."chat_members" USING "btree" ("last_read_message_id");


--

-- Name: idx_chat_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chat_members_user" ON "public"."chat_members" USING "btree" ("user_id");


--

-- Name: idx_chat_members_user_id_is_archived; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chat_members_user_id_is_archived" ON "public"."chat_members" USING "btree" ("user_id", "is_archived");


--

-- Name: idx_chat_members_user_sync; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_chat_members_user_sync" ON "public"."chat_members" USING "btree" ("user_id", "is_pinned", "is_archived");


--

-- Name: chat_members chat_members_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON DELETE CASCADE;


--

-- Name: chat_members chat_members_last_delivered_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_last_delivered_message_id_fkey" FOREIGN KEY ("last_delivered_message_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;


--

-- Name: chat_members chat_members_last_read_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_last_read_message_id_fkey" FOREIGN KEY ("last_read_message_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;


--

-- Name: chat_members chat_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
