-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: redeem_codes redeem_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."redeem_codes"
    ADD CONSTRAINT "redeem_codes_code_key" UNIQUE ("code");


--

-- Name: redeem_codes redeem_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."redeem_codes"
    ADD CONSTRAINT "redeem_codes_pkey" PRIMARY KEY ("id");


--
