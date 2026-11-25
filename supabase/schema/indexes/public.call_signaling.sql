-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: call_signaling call_signaling_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."call_signaling"
    ADD CONSTRAINT "call_signaling_pkey" PRIMARY KEY ("id");


--

-- Name: idx_call_signaling_call_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_call_signaling_call_id" ON "public"."call_signaling" USING "btree" ("call_id");


--

-- Name: call_signaling call_signaling_call_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."call_signaling"
    ADD CONSTRAINT "call_signaling_call_id_fkey" FOREIGN KEY ("call_id") REFERENCES "public"."call_sessions"("id") ON DELETE CASCADE;


--

-- Name: call_signaling call_signaling_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."call_signaling"
    ADD CONSTRAINT "call_signaling_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
