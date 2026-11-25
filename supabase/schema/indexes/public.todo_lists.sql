-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: todo_lists todo_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."todo_lists"
    ADD CONSTRAINT "todo_lists_pkey" PRIMARY KEY ("id");


--

-- Name: idx_todo_lists_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_todo_lists_user_id" ON "public"."todo_lists" USING "btree" ("user_id");


--

-- Name: todo_lists todo_lists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."todo_lists"
    ADD CONSTRAINT "todo_lists_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
