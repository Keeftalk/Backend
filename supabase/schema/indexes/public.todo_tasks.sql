-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: todo_tasks todo_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."todo_tasks"
    ADD CONSTRAINT "todo_tasks_pkey" PRIMARY KEY ("id");


--

-- Name: idx_todo_tasks_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_todo_tasks_user_id" ON "public"."todo_tasks" USING "btree" ("user_id");


--

-- Name: todo_tasks todo_tasks_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."todo_tasks"
    ADD CONSTRAINT "todo_tasks_list_id_fkey" FOREIGN KEY ("list_id") REFERENCES "public"."todo_lists"("id") ON DELETE SET NULL;


--

-- Name: todo_tasks todo_tasks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."todo_tasks"
    ADD CONSTRAINT "todo_tasks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
