-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_nicknames caller_nicknames_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_nicknames"
    ADD CONSTRAINT "caller_nicknames_pkey" PRIMARY KEY ("phone_hash", "nickname");


--
