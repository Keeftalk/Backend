-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--

-- Name: TABLE "conversation_keys"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."conversation_keys" IS 'Stores conversation encryption keys (PCKs) wrapped with the user AEK for multi-device sync.';


--

-- Name: COLUMN "user_security_settings"."encrypted_account_key"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."user_security_settings"."encrypted_account_key" IS 'User root Account Encryption Key (AEK) wrapped by password-derived KEK.';


--

-- Name: COLUMN "user_settings"."feed_settings"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."user_settings"."feed_settings" IS 'User personalized feed preferences (including maxArticlesToCache, salat, weather, markets)';


--

-- Name: COLUMN "user_settings"."browser_settings"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."user_settings"."browser_settings" IS 'User browser privacy and search settings';


--
