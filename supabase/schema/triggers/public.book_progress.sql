-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: book_progress update_book_progress_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_book_progress_updated_at" BEFORE UPDATE ON "public"."book_progress" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
