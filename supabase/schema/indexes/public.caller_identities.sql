-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: caller_identities caller_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."caller_identities"
    ADD CONSTRAINT "caller_identities_pkey" PRIMARY KEY ("phone_hash");


--
