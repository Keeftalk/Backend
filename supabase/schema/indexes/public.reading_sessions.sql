-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: reading_sessions reading_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_pkey" PRIMARY KEY ("id");


--

-- Name: idx_reading_sessions_book_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_reading_sessions_book_id" ON "public"."reading_sessions" USING "btree" ("book_id");


--

-- Name: idx_reading_sessions_start_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_reading_sessions_start_time" ON "public"."reading_sessions" USING "btree" ("start_time");


--

-- Name: idx_reading_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_reading_sessions_user_id" ON "public"."reading_sessions" USING "btree" ("user_id");


--

-- Name: reading_sessions reading_sessions_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;


--
