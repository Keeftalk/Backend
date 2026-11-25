-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--

-- Name: FUNCTION "add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_file_envelope"("target_file_id" "uuid", "new_envelope" "jsonb") TO "service_role";


--

-- Name: FUNCTION "calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_relationship_strength"("user_id_a" "text", "user_id_b" "text") TO "service_role";


--

-- Name: FUNCTION "calculate_user_storage_usage"("target_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "calculate_user_storage_usage"("target_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_user_storage_usage"("target_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "can_request_data_export"("p_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_request_data_export"("p_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."can_request_data_export"("p_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_request_data_export"("p_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "can_upload_file"("p_user_id" "text", "p_file_size" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "text", "p_file_size" bigint) TO "service_role";


--

-- Name: FUNCTION "can_upload_file"("p_user_id" "uuid", "p_file_size" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_upload_file"("p_user_id" "uuid", "p_file_size" bigint) TO "service_role";


--

-- Name: FUNCTION "check_can_message"("target_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_can_message"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_can_message"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_can_message"("target_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "check_chat_access"("chat_uuid" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_chat_access"("chat_uuid" "uuid") TO "service_role";


--

-- Name: FUNCTION "check_family_member_limit"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_family_member_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_family_member_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_family_member_limit"() TO "service_role";


--

-- Name: FUNCTION "check_family_member_removal"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_family_member_removal"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_family_member_removal"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_family_member_removal"() TO "service_role";


--

-- Name: FUNCTION "check_file_access"("target_file_id" "uuid", "target_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_file_access"("target_file_id" "uuid", "target_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "check_file_upload_limits"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_file_upload_limits"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_file_upload_limits"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_file_upload_limits"() TO "service_role";


--

-- Name: FUNCTION "check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_is_family_member"("p_user_id" "uuid", "p_member_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "check_membership"("p_chat_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_membership"("p_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_membership"("p_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_membership"("p_chat_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "check_vault_invite"("invite_token_hash" "text", "log_action" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_vault_invite"("invite_token_hash" "text", "log_action" boolean) TO "service_role";


--

-- Name: FUNCTION "check_vault_share"("share_token" "text", "log_action" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_vault_share"("share_token" "text", "log_action" boolean) TO "service_role";


--

-- Name: FUNCTION "cleanup_expired_entitlements"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."cleanup_expired_entitlements"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_expired_entitlements"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_expired_entitlements"() TO "service_role";


--

-- Name: FUNCTION "complete_user_onboarding"("p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_user_onboarding"("p_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "contribute_caller_id"("p_phone_identifier" "text", "p_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id"("p_phone_identifier" "text", "p_name" "text") TO "service_role";


--

-- Name: FUNCTION "contribute_caller_id_batch_v3"("p_contributions" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_batch_v3"("p_contributions" "jsonb") TO "service_role";


--

-- Name: FUNCTION "contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v2"("p_phone_hash" "text", "p_name" "text") TO "service_role";


--

-- Name: FUNCTION "contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contribute_caller_id_v3"("p_phone_hash" "text", "p_first_name" "text", "p_family_name" "text", "p_nickname" "text", "p_business_name" "text") TO "service_role";


--

-- Name: FUNCTION "decrement_file_reference"("target_file_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."decrement_file_reference"("target_file_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."deduct_prepaid_usage"("p_user_id" "uuid", "p_amount" numeric, "p_idempotency_key" "text", "p_description" "text") TO "service_role";


--

-- Name: FUNCTION "delete_expired_messages"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."delete_expired_messages"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_expired_messages"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_expired_messages"() TO "service_role";


--

-- Name: FUNCTION "delete_message_for_everyone"("p_message_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_message_for_everyone"("p_message_id" "text") TO "service_role";


--

-- Name: FUNCTION "edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."edit_message"("p_message_id" "text", "p_ciphertext" "text", "p_nonce" "text", "p_crypto_version" integer) TO "service_role";


--

-- Name: FUNCTION "enforce_name_change_cooldown"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."enforce_name_change_cooldown"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_name_change_cooldown"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_name_change_cooldown"() TO "service_role";


--

-- Name: FUNCTION "generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_bulk_redeem_codes"("p_count" integer, "p_prefix" "text", "p_type" "text", "p_plan_type" "text", "p_storage_limit" bigint, "p_feature_keys" "text"[], "p_max_uses" integer, "p_expires_in_days" integer) TO "service_role";


--

-- Name: FUNCTION "get_active_first_contact_policy"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_active_first_contact_policy"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_active_first_contact_policy"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_active_first_contact_policy"() TO "service_role";


--

-- Name: FUNCTION "get_broadcast_analytics"("p_broadcast_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_broadcast_analytics"("p_broadcast_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "get_caller_id_pepper"(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."get_caller_id_pepper"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_caller_id_pepper"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_caller_id_pepper"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_caller_id_pepper"() TO "service_role";


--

-- Name: FUNCTION "get_community_analytics"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_community_analytics"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_community_analytics"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_community_analytics"() TO "service_role";


--

-- Name: FUNCTION "get_connection_paths"("target_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_connection_paths"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_connection_paths"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_connection_paths"("target_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "get_my_chat_ids"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_my_chat_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_chat_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_chat_ids"() TO "service_role";


--

-- Name: FUNCTION "get_my_chats"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_my_chats"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_chats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_chats"() TO "service_role";


--

-- Name: FUNCTION "get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_assign_user_storage_region"("p_user_id" "uuid", "p_country_code" "text", "p_storage_region" "text", "p_private_bucket" "text", "p_public_bucket" "text", "p_market_bucket" "text", "p_detention_bucket" "text", "p_backups_bucket" "text") TO "service_role";


--

-- Name: FUNCTION "get_or_create_1to1_chat"("other_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_1to1_chat"("other_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "get_or_create_ai_chat"("bot_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_ai_chat"("bot_id" "text") TO "service_role";


--

-- Name: FUNCTION "get_or_create_official_chat"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_or_create_official_chat"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_official_chat"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_official_chat"() TO "service_role";


--

-- Name: FUNCTION "get_relationship_summary"("target_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_relationship_summary"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_relationship_summary"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_relationship_summary"("target_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "get_user_entitlements"("p_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "get_user_entitlements"("p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_entitlements"("p_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "handle_app_customization_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_app_customization_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_app_customization_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_app_customization_updated_at"() TO "service_role";


--

-- Name: FUNCTION "handle_heartbeat"("uid" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_heartbeat"("uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_heartbeat"("uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_heartbeat"("uid" "uuid") TO "service_role";


--

-- Name: FUNCTION "handle_message_sync_update"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_message_sync_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_message_sync_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_message_sync_update"() TO "service_role";


--

-- Name: FUNCTION "handle_new_message"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_message"() TO "service_role";


--

-- Name: FUNCTION "handle_new_message_sync"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_message_sync"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_message_sync"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_message_sync"() TO "service_role";


--

-- Name: FUNCTION "handle_new_profile_privacy"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_profile_privacy"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_profile_privacy"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_profile_privacy"() TO "service_role";


--

-- Name: FUNCTION "handle_new_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


--

-- Name: FUNCTION "handle_new_user_profile"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_user_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_profile"() TO "service_role";


--

-- Name: FUNCTION "handle_new_user_settings"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_user_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_settings"() TO "service_role";


--

-- Name: FUNCTION "handle_profile_phone_hmac"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_profile_phone_hmac"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_profile_phone_hmac"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_profile_phone_hmac"() TO "service_role";


--

-- Name: FUNCTION "handle_profile_view_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_profile_view_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_profile_view_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_profile_view_notification"() TO "service_role";


--

-- Name: FUNCTION "handle_security_event_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_security_event_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_security_event_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_security_event_notification"() TO "service_role";


--

-- Name: FUNCTION "handle_team_member_upgrade"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_team_member_upgrade"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_team_member_upgrade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_team_member_upgrade"() TO "service_role";


--

-- Name: FUNCTION "handle_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";


--

-- Name: FUNCTION "handle_visibility_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_visibility_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_visibility_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_visibility_updated_at"() TO "service_role";


--

-- Name: FUNCTION "increment_file_reference"("target_file_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_file_reference"("target_file_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "increment_import_progress"("import_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_import_progress"("import_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_import_progress"("import_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_import_progress"("import_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "increment_profile_view_count"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_profile_view_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_profile_view_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_profile_view_count"() TO "service_role";


--

-- Name: FUNCTION "increment_share_download"("share_token" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_share_download"("share_token" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_share_download"("share_token" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_share_download"("share_token" "text") TO "service_role";


--

-- Name: FUNCTION "increment_story_like"("p_story_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_story_like"("p_story_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_story_like"("p_story_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_story_like"("p_story_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "increment_story_view"("p_story_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_story_view"("p_story_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_story_view"("p_story_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_story_view"("p_story_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "initialize_user_customization"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."initialize_user_customization"() TO "anon";
GRANT ALL ON FUNCTION "public"."initialize_user_customization"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."initialize_user_customization"() TO "service_role";


--

-- Name: FUNCTION "internal_base32_decode"("p_base32" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."internal_base32_decode"("p_base32" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."internal_base32_decode"("p_base32" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_base32_decode"("p_base32" "text") TO "service_role";


--

-- Name: FUNCTION "internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_compute_totp"("p_secret_base32" "text", "p_timestamp" timestamp with time zone) TO "service_role";


--

-- Name: FUNCTION "internal_random_base32_secret"("p_length" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."internal_random_base32_secret"("p_length" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."internal_random_base32_secret"("p_length" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_random_base32_secret"("p_length" integer) TO "service_role";


--

-- Name: FUNCTION "internal_verify_totp"("p_secret_base32" "text", "p_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."internal_verify_totp"("p_secret_base32" "text", "p_code" "text") TO "service_role";


--

-- Name: FUNCTION "is_admin_of"("p_chat_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_of"("p_chat_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "is_chat_member"("target_chat_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_chat_member"("target_chat_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_chat_member"("target_chat_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_chat_member"("target_chat_id" "text") TO "service_role";


--

-- Name: FUNCTION "is_chat_member"("c_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_chat_member"("c_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_chat_participant"("p_sender_id" "uuid", "p_receiver_id" "uuid", "p_group_id" "uuid", "p_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "is_email_verified"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_email_verified"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_email_verified"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_email_verified"() TO "service_role";


--

-- Name: FUNCTION "is_group_member"("p_group_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "is_group_member"("p_group_id" "uuid", "p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_group_member"("p_group_id" "uuid", "p_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "is_keeftalk_employee"("p_email" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_keeftalk_employee"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_keeftalk_employee"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_keeftalk_employee"("p_email" "text") TO "service_role";


--

-- Name: FUNCTION "is_member_of"("p_chat_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_member_of"("p_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_member_of"("p_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_member_of"("p_chat_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_social_connected"("user_id_a" "uuid", "user_id_b" "uuid") TO "service_role";


--

-- Name: FUNCTION "log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_analytics_batch"("p_sessions" "jsonb", "p_screens" "jsonb", "p_chats" "jsonb", "p_media" "jsonb") TO "service_role";


--

-- Name: FUNCTION "lookup_caller_id"("phone_numbers" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lookup_caller_id"("phone_numbers" "text"[]) TO "service_role";


--

-- Name: FUNCTION "lookup_caller_id_v2"("phone_hashes" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v2"("phone_hashes" "text"[]) TO "service_role";


--

-- Name: FUNCTION "lookup_caller_id_v3"("phone_hashes" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lookup_caller_id_v3"("phone_hashes" "text"[]) TO "service_role";


--

-- Name: FUNCTION "notify_new_message"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."notify_new_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_new_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_new_message"() TO "service_role";


--

-- Name: FUNCTION "notify_security_event"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."notify_security_event"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_security_event"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_security_event"() TO "service_role";


--

-- Name: FUNCTION "notify_session_revoked"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."notify_session_revoked"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_session_revoked"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_session_revoked"() TO "service_role";


--

-- Name: FUNCTION "on_message_update_relationship_strength"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."on_message_update_relationship_strength"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_message_update_relationship_strength"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_message_update_relationship_strength"() TO "service_role";


--

-- Name: FUNCTION "on_official_message_sent"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."on_official_message_sent"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_official_message_sent"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_official_message_sent"() TO "service_role";


--

-- Name: FUNCTION "on_vault_import_started"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."on_vault_import_started"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_vault_import_started"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_vault_import_started"() TO "service_role";


--

-- Name: FUNCTION "protect_parental_controls"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."protect_parental_controls"() TO "anon";
GRANT ALL ON FUNCTION "public"."protect_parental_controls"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."protect_parental_controls"() TO "service_role";


--

-- Name: FUNCTION "purge_expired_market_listings"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."purge_expired_market_listings"() TO "anon";
GRANT ALL ON FUNCTION "public"."purge_expired_market_listings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."purge_expired_market_listings"() TO "service_role";


--

-- Name: FUNCTION "recalculate_caller_id_consensus_v3"("p_phone_hash" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."recalculate_caller_id_consensus_v3"("p_phone_hash" "text") TO "service_role";


--

-- Name: FUNCTION "redeem_code"("p_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."redeem_code"("p_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."redeem_code"("p_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."redeem_code"("p_code" "text") TO "service_role";


--

-- Name: FUNCTION "redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."redeem_subscription_key_atomic"("p_key_id" "uuid", "p_user_id" "uuid", "p_entitlement_start" timestamp with time zone, "p_entitlement_expiration" timestamp with time zone, "p_plan" "public"."subscription_plan", "p_storage_bytes" bigint, "p_lifetime" boolean) TO "service_role";


--

-- Name: FUNCTION "reply_to_message_request"("p_request_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."reply_to_message_request"("p_request_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."reply_to_message_request"("p_request_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reply_to_message_request"("p_request_id" "text") TO "service_role";


--

-- Name: FUNCTION "report_caller_id_spam"("p_phone_identifier" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."report_caller_id_spam"("p_phone_identifier" "text") TO "service_role";


--

-- Name: FUNCTION "report_caller_id_spam_v2"("p_phone_hash" "text"); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."report_caller_id_spam_v2"("p_phone_hash" "text") TO "service_role";


--

-- Name: FUNCTION "rls_auto_enable"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";


--

-- Name: FUNCTION "rpc_begin_totp_enrollment"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_begin_totp_enrollment"() TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_begin_totp_enrollment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_begin_totp_enrollment"() TO "service_role";


--

-- Name: FUNCTION "rpc_create_2fa_login_challenge"("p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_create_2fa_login_challenge"("p_user_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "rpc_disable_2fa_method"("p_factor_type" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_disable_2fa_method"("p_factor_type" "text") TO "service_role";


--

-- Name: FUNCTION "rpc_generate_backup_codes"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_generate_backup_codes"() TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_generate_backup_codes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_generate_backup_codes"() TO "service_role";


--

-- Name: FUNCTION "rpc_get_2fa_status"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_get_2fa_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_get_2fa_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_get_2fa_status"() TO "service_role";


--

-- Name: FUNCTION "rpc_request_email_otp"("p_purpose" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_request_email_otp"("p_purpose" "text") TO "service_role";


--

-- Name: FUNCTION "rpc_request_sms_otp"("p_purpose" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_request_sms_otp"("p_purpose" "text") TO "service_role";


--

-- Name: FUNCTION "rpc_set_preferred_2fa_method"("p_factor_type" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_set_preferred_2fa_method"("p_factor_type" "text") TO "service_role";


--

-- Name: FUNCTION "rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_verify_2fa_login_challenge"("p_login_challenge_id" "uuid", "p_factor_type" "text", "p_code" "text") TO "service_role";


--

-- Name: FUNCTION "rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_verify_otp_challenge"("p_challenge_id" "uuid", "p_otp_code" "text") TO "service_role";


--

-- Name: FUNCTION "rpc_verify_totp_enrollment"("p_totp_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_verify_totp_enrollment"("p_totp_code" "text") TO "service_role";


--

-- Name: FUNCTION "safe_check_note_owner"("n_id" "uuid", "u_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."safe_check_note_owner"("n_id" "uuid", "u_id" "uuid") TO "service_role";


--

-- Name: FUNCTION "send_nudge"("target_user_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text") TO "service_role";


--

-- Name: FUNCTION "send_nudge"("target_user_id" "text", "nudge_increment" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_nudge"("target_user_id" "text", "nudge_increment" integer) TO "service_role";


--

-- Name: FUNCTION "set_user_plan"("p_user_id" "text", "p_plan" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "text", "p_plan" "text") TO "service_role";


--

-- Name: FUNCTION "set_user_plan"("p_user_id" "uuid", "p_plan" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_plan"("p_user_id" "uuid", "p_plan" "text") TO "service_role";


--

-- Name: FUNCTION "sync_chat_last_message"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."sync_chat_last_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_chat_last_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_chat_last_message"() TO "service_role";


--

-- Name: FUNCTION "sync_chat_status_from_pointers"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."sync_chat_status_from_pointers"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_chat_status_from_pointers"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_chat_status_from_pointers"() TO "service_role";


--

-- Name: FUNCTION "sync_family_member_benefits"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."sync_family_member_benefits"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_family_member_benefits"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_family_member_benefits"() TO "service_role";


--

-- Name: FUNCTION "sync_official_broadcasts"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."sync_official_broadcasts"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_official_broadcasts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_official_broadcasts"() TO "service_role";


--

-- Name: FUNCTION "sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "text", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "service_role";


--

-- Name: FUNCTION "sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_subscription_entitlement"("target_user_id" "uuid", "new_plan" "public"."subscription_plan", "new_limit" bigint, "new_status" "text", "new_expiry" timestamp with time zone, "new_purchase_token" "text", "new_order_id" "text") TO "service_role";


--

-- Name: FUNCTION "sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_time_tracking"("p_epoch_day" bigint, "p_feature_key" "text", "p_add_seconds" bigint) TO "service_role";


--

-- Name: FUNCTION "toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_pinned_message"("p_chat_id" "uuid", "p_message_id" "uuid", "p_is_pinned" boolean) TO "service_role";


--

-- Name: FUNCTION "track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_broadcast_action"("p_broadcast_id" "uuid", "p_action_type" "text", "p_metadata" "jsonb") TO "service_role";


--

-- Name: FUNCTION "trigger_fcm_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."trigger_fcm_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_fcm_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_fcm_notification"() TO "service_role";


--

-- Name: FUNCTION "update_chat_last_activity"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_chat_last_activity"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_chat_last_activity"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_chat_last_activity"() TO "service_role";


--

-- Name: FUNCTION "update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_child_control"("target_user_id" "uuid", "comm_rest" "jsonb", "cont_rest" "jsonb", "usage_lim" "jsonb") TO "service_role";


--

-- Name: FUNCTION "update_extension_install_stats"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_extension_install_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_extension_install_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_extension_install_stats"() TO "service_role";


--

-- Name: FUNCTION "update_extension_rating_stats"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_extension_rating_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_extension_rating_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_extension_rating_stats"() TO "service_role";


--

-- Name: FUNCTION "update_file_reference_count"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_file_reference_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_file_reference_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_file_reference_count"() TO "service_role";


--

-- Name: FUNCTION "update_profile_storage_usage"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_profile_storage_usage"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile_storage_usage"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile_storage_usage"() TO "service_role";


--

-- Name: FUNCTION "update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "uuid", "p_file_size" bigint) TO "service_role";


--

-- Name: FUNCTION "update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_storage_usage"("p_user_id" "text", "p_file_size" bigint, "p_file_type" "text") TO "service_role";


--

-- Name: FUNCTION "update_updated_at_column"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


--

-- Name: FUNCTION "update_user_active_benefits"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_user_active_benefits"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_active_benefits"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_active_benefits"() TO "service_role";


--

-- Name: FUNCTION "upsert_typing_status"("payload" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."upsert_typing_status"("payload" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_typing_status"("payload" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_typing_status"("payload" "jsonb") TO "service_role";


--

-- Name: FUNCTION "upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_user_xp_and_get_rank"("p_total_xp" bigint, "p_username" "text") TO "service_role";


--

-- Name: FUNCTION "validate_background_media"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."validate_background_media"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_background_media"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_background_media"() TO "service_role";


--

-- Name: TABLE "BIN_DB"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."BIN_DB" TO "anon";
GRANT ALL ON TABLE "public"."BIN_DB" TO "authenticated";
GRANT ALL ON TABLE "public"."BIN_DB" TO "service_role";


--

-- Name: TABLE "account_deletions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."account_deletions" TO "anon";
GRANT ALL ON TABLE "public"."account_deletions" TO "authenticated";
GRANT ALL ON TABLE "public"."account_deletions" TO "service_role";


--

-- Name: TABLE "admin_users"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."admin_users" TO "anon";
GRANT ALL ON TABLE "public"."admin_users" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_users" TO "service_role";


--

-- Name: TABLE "agenda_attachment"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."agenda_attachment" TO "anon";
GRANT ALL ON TABLE "public"."agenda_attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."agenda_attachment" TO "service_role";


--

-- Name: TABLE "ai_chat_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."ai_chat_settings" TO "anon";
GRANT ALL ON TABLE "public"."ai_chat_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_chat_settings" TO "service_role";


--

-- Name: TABLE "ai_credentials"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."ai_credentials" TO "anon";
GRANT ALL ON TABLE "public"."ai_credentials" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_credentials" TO "service_role";


--

-- Name: TABLE "ai_memories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."ai_memories" TO "anon";
GRANT ALL ON TABLE "public"."ai_memories" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_memories" TO "service_role";


--

-- Name: TABLE "ai_provider_configs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."ai_provider_configs" TO "anon";
GRANT ALL ON TABLE "public"."ai_provider_configs" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_provider_configs" TO "service_role";


--

-- Name: TABLE "app_config"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."app_config" TO "anon";
GRANT ALL ON TABLE "public"."app_config" TO "authenticated";
GRANT ALL ON TABLE "public"."app_config" TO "service_role";


--

-- Name: TABLE "billing_audit_log"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_audit_log" TO "anon";
GRANT ALL ON TABLE "public"."billing_audit_log" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_audit_log" TO "service_role";


--

-- Name: TABLE "billing_balances"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_balances" TO "anon";
GRANT ALL ON TABLE "public"."billing_balances" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_balances" TO "service_role";


--

-- Name: TABLE "billing_invoices"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_invoices" TO "anon";
GRANT ALL ON TABLE "public"."billing_invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_invoices" TO "service_role";


--

-- Name: TABLE "billing_ledger"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_ledger" TO "anon";
GRANT ALL ON TABLE "public"."billing_ledger" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_ledger" TO "service_role";


--

-- Name: TABLE "billing_payments"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_payments" TO "anon";
GRANT ALL ON TABLE "public"."billing_payments" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_payments" TO "service_role";


--

-- Name: TABLE "billing_preferences"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_preferences" TO "anon";
GRANT ALL ON TABLE "public"."billing_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_preferences" TO "service_role";


--

-- Name: TABLE "billing_pricing"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_pricing" TO "anon";
GRANT ALL ON TABLE "public"."billing_pricing" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_pricing" TO "service_role";


--

-- Name: TABLE "billing_usage"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."billing_usage" TO "anon";
GRANT ALL ON TABLE "public"."billing_usage" TO "authenticated";
GRANT ALL ON TABLE "public"."billing_usage" TO "service_role";


--

-- Name: TABLE "blocked_users"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."blocked_users" TO "anon";
GRANT ALL ON TABLE "public"."blocked_users" TO "authenticated";
GRANT ALL ON TABLE "public"."blocked_users" TO "service_role";


--

-- Name: TABLE "book_achievements"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."book_achievements" TO "anon";
GRANT ALL ON TABLE "public"."book_achievements" TO "authenticated";
GRANT ALL ON TABLE "public"."book_achievements" TO "service_role";


--

-- Name: TABLE "book_bookmarks"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."book_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."book_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."book_bookmarks" TO "service_role";


--

-- Name: TABLE "book_collection_ref"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."book_collection_ref" TO "anon";
GRANT ALL ON TABLE "public"."book_collection_ref" TO "authenticated";
GRANT ALL ON TABLE "public"."book_collection_ref" TO "service_role";


--

-- Name: TABLE "book_collections"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."book_collections" TO "anon";
GRANT ALL ON TABLE "public"."book_collections" TO "authenticated";
GRANT ALL ON TABLE "public"."book_collections" TO "service_role";


--

-- Name: TABLE "book_progress"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."book_progress" TO "anon";
GRANT ALL ON TABLE "public"."book_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."book_progress" TO "service_role";


--

-- Name: TABLE "book_quotes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."book_quotes" TO "anon";
GRANT ALL ON TABLE "public"."book_quotes" TO "authenticated";
GRANT ALL ON TABLE "public"."book_quotes" TO "service_role";


--

-- Name: TABLE "books"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."books" TO "anon";
GRANT ALL ON TABLE "public"."books" TO "authenticated";
GRANT ALL ON TABLE "public"."books" TO "service_role";


--

-- Name: TABLE "broadcasts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."broadcasts" TO "anon";
GRANT ALL ON TABLE "public"."broadcasts" TO "authenticated";
GRANT ALL ON TABLE "public"."broadcasts" TO "service_role";


--

-- Name: TABLE "browser_bookmarks"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."browser_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."browser_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."browser_bookmarks" TO "service_role";


--

-- Name: TABLE "browser_history"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."browser_history" TO "anon";
GRANT ALL ON TABLE "public"."browser_history" TO "authenticated";
GRANT ALL ON TABLE "public"."browser_history" TO "service_role";


--

-- Name: TABLE "bug_reports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."bug_reports" TO "anon";
GRANT ALL ON TABLE "public"."bug_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."bug_reports" TO "service_role";


--

-- Name: TABLE "calendar_categories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."calendar_categories" TO "anon";
GRANT ALL ON TABLE "public"."calendar_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_categories" TO "service_role";


--

-- Name: TABLE "calendar_invitations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."calendar_invitations" TO "anon";
GRANT ALL ON TABLE "public"."calendar_invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_invitations" TO "service_role";


--

-- Name: TABLE "calendar_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."calendar_items" TO "anon";
GRANT ALL ON TABLE "public"."calendar_items" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_items" TO "service_role";


--

-- Name: TABLE "call_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."call_logs" TO "anon";
GRANT ALL ON TABLE "public"."call_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."call_logs" TO "service_role";


--

-- Name: TABLE "call_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."call_sessions" TO "anon";
GRANT ALL ON TABLE "public"."call_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."call_sessions" TO "service_role";


--

-- Name: TABLE "call_signaling"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."call_signaling" TO "anon";
GRANT ALL ON TABLE "public"."call_signaling" TO "authenticated";
GRANT ALL ON TABLE "public"."call_signaling" TO "service_role";


--

-- Name: TABLE "caller_contributions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."caller_contributions" TO "anon";
GRANT ALL ON TABLE "public"."caller_contributions" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_contributions" TO "service_role";


--

-- Name: TABLE "caller_id_config"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."caller_id_config" TO "anon";
GRANT ALL ON TABLE "public"."caller_id_config" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_id_config" TO "service_role";


--

-- Name: TABLE "caller_id_quotas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."caller_id_quotas" TO "anon";
GRANT ALL ON TABLE "public"."caller_id_quotas" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_id_quotas" TO "service_role";


--

-- Name: TABLE "caller_identities"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."caller_identities" TO "anon";
GRANT ALL ON TABLE "public"."caller_identities" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_identities" TO "service_role";


--

-- Name: TABLE "caller_nicknames"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."caller_nicknames" TO "anon";
GRANT ALL ON TABLE "public"."caller_nicknames" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_nicknames" TO "service_role";


--

-- Name: TABLE "caller_spam_reporters"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."caller_spam_reporters" TO "anon";
GRANT ALL ON TABLE "public"."caller_spam_reporters" TO "authenticated";
GRANT ALL ON TABLE "public"."caller_spam_reporters" TO "service_role";


--

-- Name: TABLE "chat_containers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."chat_containers" TO "anon";
GRANT ALL ON TABLE "public"."chat_containers" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_containers" TO "service_role";


--

-- Name: TABLE "chat_members"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."chat_members" TO "anon";
GRANT ALL ON TABLE "public"."chat_members" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_members" TO "service_role";


--

-- Name: TABLE "chats"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."chats" TO "anon";
GRANT ALL ON TABLE "public"."chats" TO "authenticated";
GRANT ALL ON TABLE "public"."chats" TO "service_role";


--

-- Name: TABLE "profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";


--

-- Name: TABLE "chat_list_metadata"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."chat_list_metadata" TO "anon";
GRANT ALL ON TABLE "public"."chat_list_metadata" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_list_metadata" TO "service_role";


--

-- Name: TABLE "chat_reports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."chat_reports" TO "anon";
GRANT ALL ON TABLE "public"."chat_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_reports" TO "service_role";


--

-- Name: TABLE "community_growth_daily"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."community_growth_daily" TO "anon";
GRANT ALL ON TABLE "public"."community_growth_daily" TO "authenticated";
GRANT ALL ON TABLE "public"."community_growth_daily" TO "service_role";


--

-- Name: TABLE "contacts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."contacts" TO "anon";
GRANT ALL ON TABLE "public"."contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."contacts" TO "service_role";


--

-- Name: TABLE "connections"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."connections" TO "anon";
GRANT ALL ON TABLE "public"."connections" TO "authenticated";
GRANT ALL ON TABLE "public"."connections" TO "service_role";


--

-- Name: TABLE "conversation_keys"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."conversation_keys" TO "anon";
GRANT ALL ON TABLE "public"."conversation_keys" TO "authenticated";
GRANT ALL ON TABLE "public"."conversation_keys" TO "service_role";


--

-- Name: TABLE "data_exports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."data_exports" TO "anon";
GRANT ALL ON TABLE "public"."data_exports" TO "authenticated";
GRANT ALL ON TABLE "public"."data_exports" TO "service_role";


--

-- Name: TABLE "families"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."families" TO "anon";
GRANT ALL ON TABLE "public"."families" TO "authenticated";
GRANT ALL ON TABLE "public"."families" TO "service_role";


--

-- Name: TABLE "family_groups"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."family_groups" TO "anon";
GRANT ALL ON TABLE "public"."family_groups" TO "authenticated";
GRANT ALL ON TABLE "public"."family_groups" TO "service_role";


--

-- Name: TABLE "family_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."family_permissions" TO "anon";
GRANT ALL ON TABLE "public"."family_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."family_permissions" TO "service_role";


--

-- Name: TABLE "feature_sync_plans"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."feature_sync_plans" TO "anon";
GRANT ALL ON TABLE "public"."feature_sync_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."feature_sync_plans" TO "service_role";


--

-- Name: TABLE "files"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."files" TO "anon";
GRANT ALL ON TABLE "public"."files" TO "authenticated";
GRANT ALL ON TABLE "public"."files" TO "service_role";


--

-- Name: TABLE "habit_checkins"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."habit_checkins" TO "anon";
GRANT ALL ON TABLE "public"."habit_checkins" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_checkins" TO "service_role";


--

-- Name: TABLE "habit_grace_uses"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."habit_grace_uses" TO "anon";
GRANT ALL ON TABLE "public"."habit_grace_uses" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_grace_uses" TO "service_role";


--

-- Name: TABLE "habit_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."habit_logs" TO "anon";
GRANT ALL ON TABLE "public"."habit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_logs" TO "service_role";


--

-- Name: TABLE "habit_milestones"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."habit_milestones" TO "anon";
GRANT ALL ON TABLE "public"."habit_milestones" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_milestones" TO "service_role";


--

-- Name: TABLE "habit_schedules"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."habit_schedules" TO "anon";
GRANT ALL ON TABLE "public"."habit_schedules" TO "authenticated";
GRANT ALL ON TABLE "public"."habit_schedules" TO "service_role";


--

-- Name: TABLE "habits"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."habits" TO "anon";
GRANT ALL ON TABLE "public"."habits" TO "authenticated";
GRANT ALL ON TABLE "public"."habits" TO "service_role";


--

-- Name: TABLE "invitation_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."invitation_permissions" TO "anon";
GRANT ALL ON TABLE "public"."invitation_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."invitation_permissions" TO "service_role";


--

-- Name: TABLE "legal_documents"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."legal_documents" TO "anon";
GRANT ALL ON TABLE "public"."legal_documents" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_documents" TO "service_role";


--

-- Name: TABLE "link_previews"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."link_previews" TO "anon";
GRANT ALL ON TABLE "public"."link_previews" TO "authenticated";
GRANT ALL ON TABLE "public"."link_previews" TO "service_role";


--

-- Name: TABLE "login_attempts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."login_attempts" TO "anon";
GRANT ALL ON TABLE "public"."login_attempts" TO "authenticated";
GRANT ALL ON TABLE "public"."login_attempts" TO "service_role";


--

-- Name: TABLE "market_categories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_categories" TO "anon";
GRANT ALL ON TABLE "public"."market_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."market_categories" TO "service_role";


--

-- Name: TABLE "market_chats"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_chats" TO "anon";
GRANT ALL ON TABLE "public"."market_chats" TO "authenticated";
GRANT ALL ON TABLE "public"."market_chats" TO "service_role";


--

-- Name: TABLE "market_favorites"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_favorites" TO "anon";
GRANT ALL ON TABLE "public"."market_favorites" TO "authenticated";
GRANT ALL ON TABLE "public"."market_favorites" TO "service_role";


--

-- Name: TABLE "market_listing_extensions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_listing_extensions" TO "anon";
GRANT ALL ON TABLE "public"."market_listing_extensions" TO "authenticated";
GRANT ALL ON TABLE "public"."market_listing_extensions" TO "service_role";


--

-- Name: TABLE "market_listing_media"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_listing_media" TO "anon";
GRANT ALL ON TABLE "public"."market_listing_media" TO "authenticated";
GRANT ALL ON TABLE "public"."market_listing_media" TO "service_role";


--

-- Name: TABLE "market_listings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_listings" TO "anon";
GRANT ALL ON TABLE "public"."market_listings" TO "authenticated";
GRANT ALL ON TABLE "public"."market_listings" TO "service_role";


--

-- Name: TABLE "market_offers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_offers" TO "anon";
GRANT ALL ON TABLE "public"."market_offers" TO "authenticated";
GRANT ALL ON TABLE "public"."market_offers" TO "service_role";


--

-- Name: TABLE "market_reports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_reports" TO "anon";
GRANT ALL ON TABLE "public"."market_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."market_reports" TO "service_role";


--

-- Name: TABLE "market_saved"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_saved" TO "anon";
GRANT ALL ON TABLE "public"."market_saved" TO "authenticated";
GRANT ALL ON TABLE "public"."market_saved" TO "service_role";


--

-- Name: TABLE "market_sellers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."market_sellers" TO "anon";
GRANT ALL ON TABLE "public"."market_sellers" TO "authenticated";
GRANT ALL ON TABLE "public"."market_sellers" TO "service_role";


--

-- Name: TABLE "message_attachment"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."message_attachment" TO "anon";
GRANT ALL ON TABLE "public"."message_attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."message_attachment" TO "service_role";


--

-- Name: TABLE "message_link_previews"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."message_link_previews" TO "anon";
GRANT ALL ON TABLE "public"."message_link_previews" TO "authenticated";
GRANT ALL ON TABLE "public"."message_link_previews" TO "service_role";


--

-- Name: TABLE "message_reactions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."message_reactions" TO "anon";
GRANT ALL ON TABLE "public"."message_reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."message_reactions" TO "service_role";


--

-- Name: TABLE "message_requests"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."message_requests" TO "anon";
GRANT ALL ON TABLE "public"."message_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."message_requests" TO "service_role";


--

-- Name: TABLE "message_visibility"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."message_visibility" TO "anon";
GRANT ALL ON TABLE "public"."message_visibility" TO "authenticated";
GRANT ALL ON TABLE "public"."message_visibility" TO "service_role";


--

-- Name: TABLE "messages"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";


--

-- Name: TABLE "note_attachment"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."note_attachment" TO "anon";
GRANT ALL ON TABLE "public"."note_attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."note_attachment" TO "service_role";


--

-- Name: TABLE "note_shares"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."note_shares" TO "anon";
GRANT ALL ON TABLE "public"."note_shares" TO "authenticated";
GRANT ALL ON TABLE "public"."note_shares" TO "service_role";


--

-- Name: TABLE "notes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."notes" TO "anon";
GRANT ALL ON TABLE "public"."notes" TO "authenticated";
GRANT ALL ON TABLE "public"."notes" TO "service_role";


--

-- Name: TABLE "notes_sync_queue"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."notes_sync_queue" TO "anon";
GRANT ALL ON TABLE "public"."notes_sync_queue" TO "authenticated";
GRANT ALL ON TABLE "public"."notes_sync_queue" TO "service_role";


--

-- Name: TABLE "notifications"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";


--

-- Name: TABLE "official_broadcast_actions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."official_broadcast_actions" TO "anon";
GRANT ALL ON TABLE "public"."official_broadcast_actions" TO "authenticated";
GRANT ALL ON TABLE "public"."official_broadcast_actions" TO "service_role";


--

-- Name: TABLE "pinned_messages"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."pinned_messages" TO "anon";
GRANT ALL ON TABLE "public"."pinned_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."pinned_messages" TO "service_role";


--

-- Name: TABLE "premium_products_config"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."premium_products_config" TO "anon";
GRANT ALL ON TABLE "public"."premium_products_config" TO "authenticated";
GRANT ALL ON TABLE "public"."premium_products_config" TO "service_role";


--

-- Name: TABLE "profile_background_media"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profile_background_media" TO "anon";
GRANT ALL ON TABLE "public"."profile_background_media" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_background_media" TO "service_role";


--

-- Name: TABLE "profile_views"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profile_views" TO "anon";
GRANT ALL ON TABLE "public"."profile_views" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_views" TO "service_role";


--

-- Name: TABLE "reading_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."reading_sessions" TO "anon";
GRANT ALL ON TABLE "public"."reading_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."reading_sessions" TO "service_role";


--

-- Name: TABLE "reading_stats"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."reading_stats" TO "anon";
GRANT ALL ON TABLE "public"."reading_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."reading_stats" TO "service_role";


--

-- Name: TABLE "redeem_codes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."redeem_codes" TO "anon";
GRANT ALL ON TABLE "public"."redeem_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."redeem_codes" TO "service_role";


--

-- Name: TABLE "redeem_history"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."redeem_history" TO "anon";
GRANT ALL ON TABLE "public"."redeem_history" TO "authenticated";
GRANT ALL ON TABLE "public"."redeem_history" TO "service_role";


--

-- Name: TABLE "relationship_intelligence"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."relationship_intelligence" TO "anon";
GRANT ALL ON TABLE "public"."relationship_intelligence" TO "authenticated";
GRANT ALL ON TABLE "public"."relationship_intelligence" TO "service_role";


--

-- Name: TABLE "relationships"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."relationships" TO "anon";
GRANT ALL ON TABLE "public"."relationships" TO "authenticated";
GRANT ALL ON TABLE "public"."relationships" TO "service_role";


--

-- Name: TABLE "reports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";


--

-- Name: TABLE "secret_backup_codes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secret_backup_codes" TO "anon";
GRANT ALL ON TABLE "public"."secret_backup_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_backup_codes" TO "service_role";


--

-- Name: TABLE "secret_credentials"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secret_credentials" TO "anon";
GRANT ALL ON TABLE "public"."secret_credentials" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_credentials" TO "service_role";


--

-- Name: TABLE "secret_password_history"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secret_password_history" TO "anon";
GRANT ALL ON TABLE "public"."secret_password_history" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_password_history" TO "service_role";


--

-- Name: TABLE "secret_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secret_settings" TO "anon";
GRANT ALL ON TABLE "public"."secret_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_settings" TO "service_role";


--

-- Name: TABLE "secret_totp_accounts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secret_totp_accounts" TO "anon";
GRANT ALL ON TABLE "public"."secret_totp_accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_totp_accounts" TO "service_role";


--

-- Name: TABLE "secret_vault_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secret_vault_items" TO "anon";
GRANT ALL ON TABLE "public"."secret_vault_items" TO "authenticated";
GRANT ALL ON TABLE "public"."secret_vault_items" TO "service_role";


--

-- Name: TABLE "security_events"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."security_events" TO "anon";
GRANT ALL ON TABLE "public"."security_events" TO "authenticated";
GRANT ALL ON TABLE "public"."security_events" TO "service_role";


--

-- Name: TABLE "sms_messages"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."sms_messages" TO "anon";
GRANT ALL ON TABLE "public"."sms_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."sms_messages" TO "service_role";


--

-- Name: TABLE "sms_threads"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."sms_threads" TO "anon";
GRANT ALL ON TABLE "public"."sms_threads" TO "authenticated";
GRANT ALL ON TABLE "public"."sms_threads" TO "service_role";


--

-- Name: TABLE "storage_lifecycle_queue"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."storage_lifecycle_queue" TO "anon";
GRANT ALL ON TABLE "public"."storage_lifecycle_queue" TO "authenticated";
GRANT ALL ON TABLE "public"."storage_lifecycle_queue" TO "service_role";


--

-- Name: TABLE "store_device_install_requests"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_device_install_requests" TO "anon";
GRANT ALL ON TABLE "public"."store_device_install_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."store_device_install_requests" TO "service_role";


--

-- Name: TABLE "store_extensions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_extensions" TO "anon";
GRANT ALL ON TABLE "public"."store_extensions" TO "authenticated";
GRANT ALL ON TABLE "public"."store_extensions" TO "service_role";


--

-- Name: TABLE "store_installations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_installations" TO "anon";
GRANT ALL ON TABLE "public"."store_installations" TO "authenticated";
GRANT ALL ON TABLE "public"."store_installations" TO "service_role";


--

-- Name: TABLE "store_media_assets"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_media_assets" TO "anon";
GRANT ALL ON TABLE "public"."store_media_assets" TO "authenticated";
GRANT ALL ON TABLE "public"."store_media_assets" TO "service_role";


--

-- Name: TABLE "store_publishers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_publishers" TO "anon";
GRANT ALL ON TABLE "public"."store_publishers" TO "authenticated";
GRANT ALL ON TABLE "public"."store_publishers" TO "service_role";


--

-- Name: TABLE "store_ratings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_ratings" TO "anon";
GRANT ALL ON TABLE "public"."store_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."store_ratings" TO "service_role";


--

-- Name: TABLE "store_releases"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_releases" TO "anon";
GRANT ALL ON TABLE "public"."store_releases" TO "authenticated";
GRANT ALL ON TABLE "public"."store_releases" TO "service_role";


--

-- Name: TABLE "store_submissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."store_submissions" TO "anon";
GRANT ALL ON TABLE "public"."store_submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."store_submissions" TO "service_role";


--

-- Name: TABLE "subscription_key_redemptions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."subscription_key_redemptions" TO "anon";
GRANT ALL ON TABLE "public"."subscription_key_redemptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_key_redemptions" TO "service_role";


--

-- Name: TABLE "subscription_keys"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."subscription_keys" TO "anon";
GRANT ALL ON TABLE "public"."subscription_keys" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_keys" TO "service_role";


--

-- Name: TABLE "subscription_metadata"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."subscription_metadata" TO "anon";
GRANT ALL ON TABLE "public"."subscription_metadata" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_metadata" TO "service_role";


--

-- Name: TABLE "subscriptions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscriptions" TO "service_role";


--

-- Name: TABLE "system_metrics"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."system_metrics" TO "anon";
GRANT ALL ON TABLE "public"."system_metrics" TO "authenticated";
GRANT ALL ON TABLE "public"."system_metrics" TO "service_role";


--

-- Name: SEQUENCE "system_metrics_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."system_metrics_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."system_metrics_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."system_metrics_id_seq" TO "service_role";


--

-- Name: TABLE "todo_lists"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."todo_lists" TO "anon";
GRANT ALL ON TABLE "public"."todo_lists" TO "authenticated";
GRANT ALL ON TABLE "public"."todo_lists" TO "service_role";


--

-- Name: TABLE "todo_tasks"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."todo_tasks" TO "anon";
GRANT ALL ON TABLE "public"."todo_tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."todo_tasks" TO "service_role";


--

-- Name: TABLE "two_factor_login_challenges"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."two_factor_login_challenges" TO "anon";
GRANT ALL ON TABLE "public"."two_factor_login_challenges" TO "authenticated";
GRANT ALL ON TABLE "public"."two_factor_login_challenges" TO "service_role";


--

-- Name: TABLE "two_factor_otp_challenges"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."two_factor_otp_challenges" TO "anon";
GRANT ALL ON TABLE "public"."two_factor_otp_challenges" TO "authenticated";
GRANT ALL ON TABLE "public"."two_factor_otp_challenges" TO "service_role";


--

-- Name: TABLE "usage_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."usage_sessions" TO "anon";
GRANT ALL ON TABLE "public"."usage_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."usage_sessions" TO "service_role";


--

-- Name: TABLE "user_2fa_backup_codes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_2fa_backup_codes" TO "anon";
GRANT ALL ON TABLE "public"."user_2fa_backup_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."user_2fa_backup_codes" TO "service_role";


--

-- Name: TABLE "user_2fa_factors"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_2fa_factors" TO "anon";
GRANT ALL ON TABLE "public"."user_2fa_factors" TO "authenticated";
GRANT ALL ON TABLE "public"."user_2fa_factors" TO "service_role";


--

-- Name: TABLE "user_app_customization"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_app_customization" TO "anon";
GRANT ALL ON TABLE "public"."user_app_customization" TO "authenticated";
GRANT ALL ON TABLE "public"."user_app_customization" TO "service_role";


--

-- Name: TABLE "user_book_bookmarks"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_book_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."user_book_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_bookmarks" TO "service_role";


--

-- Name: TABLE "user_book_highlights"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_book_highlights" TO "anon";
GRANT ALL ON TABLE "public"."user_book_highlights" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_highlights" TO "service_role";


--

-- Name: TABLE "user_book_progress"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_book_progress" TO "anon";
GRANT ALL ON TABLE "public"."user_book_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_progress" TO "service_role";


--

-- Name: TABLE "user_book_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_book_sessions" TO "anon";
GRANT ALL ON TABLE "public"."user_book_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_sessions" TO "service_role";


--

-- Name: TABLE "user_book_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_book_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_book_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_book_settings" TO "service_role";


--

-- Name: TABLE "user_books"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_books" TO "anon";
GRANT ALL ON TABLE "public"."user_books" TO "authenticated";
GRANT ALL ON TABLE "public"."user_books" TO "service_role";


--

-- Name: TABLE "user_broadcast_sync"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_broadcast_sync" TO "anon";
GRANT ALL ON TABLE "public"."user_broadcast_sync" TO "authenticated";
GRANT ALL ON TABLE "public"."user_broadcast_sync" TO "service_role";


--

-- Name: TABLE "user_bundles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_bundles" TO "anon";
GRANT ALL ON TABLE "public"."user_bundles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_bundles" TO "service_role";


--

-- Name: TABLE "user_chat_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_chat_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_chat_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_chat_settings" TO "service_role";


--

-- Name: TABLE "user_controls"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_controls" TO "anon";
GRANT ALL ON TABLE "public"."user_controls" TO "authenticated";
GRANT ALL ON TABLE "public"."user_controls" TO "service_role";


--

-- Name: TABLE "user_devices"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_devices" TO "anon";
GRANT ALL ON TABLE "public"."user_devices" TO "authenticated";
GRANT ALL ON TABLE "public"."user_devices" TO "service_role";


--

-- Name: TABLE "user_doc_bookmarks"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_doc_bookmarks" TO "anon";
GRANT ALL ON TABLE "public"."user_doc_bookmarks" TO "authenticated";
GRANT ALL ON TABLE "public"."user_doc_bookmarks" TO "service_role";


--

-- Name: TABLE "user_doc_highlights"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_doc_highlights" TO "anon";
GRANT ALL ON TABLE "public"."user_doc_highlights" TO "authenticated";
GRANT ALL ON TABLE "public"."user_doc_highlights" TO "service_role";


--

-- Name: TABLE "user_doc_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_doc_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_doc_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_doc_settings" TO "service_role";


--

-- Name: TABLE "user_docs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_docs" TO "anon";
GRANT ALL ON TABLE "public"."user_docs" TO "authenticated";
GRANT ALL ON TABLE "public"."user_docs" TO "service_role";


--

-- Name: TABLE "user_drawings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_drawings" TO "anon";
GRANT ALL ON TABLE "public"."user_drawings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_drawings" TO "service_role";


--

-- Name: TABLE "user_entitlements"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_entitlements" TO "anon";
GRANT ALL ON TABLE "public"."user_entitlements" TO "authenticated";
GRANT ALL ON TABLE "public"."user_entitlements" TO "service_role";


--

-- Name: TABLE "user_feature_entitlements"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_feature_entitlements" TO "anon";
GRANT ALL ON TABLE "public"."user_feature_entitlements" TO "authenticated";
GRANT ALL ON TABLE "public"."user_feature_entitlements" TO "service_role";


--

-- Name: TABLE "user_prekeys"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_prekeys" TO "anon";
GRANT ALL ON TABLE "public"."user_prekeys" TO "authenticated";
GRANT ALL ON TABLE "public"."user_prekeys" TO "service_role";


--

-- Name: TABLE "user_presence"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_presence" TO "anon";
GRANT ALL ON TABLE "public"."user_presence" TO "authenticated";
GRANT ALL ON TABLE "public"."user_presence" TO "service_role";


--

-- Name: TABLE "user_privacy_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_privacy_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_privacy_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_privacy_settings" TO "service_role";


--

-- Name: TABLE "user_reading_xp"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_reading_xp" TO "anon";
GRANT ALL ON TABLE "public"."user_reading_xp" TO "authenticated";
GRANT ALL ON TABLE "public"."user_reading_xp" TO "service_role";


--

-- Name: TABLE "user_recovery_seeds"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_recovery_seeds" TO "service_role";


--

-- Name: TABLE "user_security_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_security_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_security_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_security_settings" TO "service_role";


--

-- Name: TABLE "user_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_sessions" TO "anon";
GRANT ALL ON TABLE "public"."user_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_sessions" TO "service_role";


--

-- Name: TABLE "user_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_settings" TO "service_role";


--

-- Name: TABLE "user_storage_regions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_storage_regions" TO "anon";
GRANT ALL ON TABLE "public"."user_storage_regions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_storage_regions" TO "service_role";


--

-- Name: TABLE "user_time_tracking"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_time_tracking" TO "anon";
GRANT ALL ON TABLE "public"."user_time_tracking" TO "authenticated";
GRANT ALL ON TABLE "public"."user_time_tracking" TO "service_role";


--

-- Name: TABLE "vault_folders"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_folders" TO "anon";
GRANT ALL ON TABLE "public"."vault_folders" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_folders" TO "service_role";


--

-- Name: TABLE "vault_invite_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_invite_logs" TO "anon";
GRANT ALL ON TABLE "public"."vault_invite_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_invite_logs" TO "service_role";


--

-- Name: TABLE "vault_item"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_item" TO "anon";
GRANT ALL ON TABLE "public"."vault_item" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_item" TO "service_role";


--

-- Name: TABLE "vault_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_items" TO "anon";
GRANT ALL ON TABLE "public"."vault_items" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_items" TO "service_role";


--

-- Name: TABLE "vault_share_imports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_share_imports" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_imports" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_imports" TO "service_role";


--

-- Name: TABLE "vault_share_invite_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_share_invite_items" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_invite_items" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_invite_items" TO "service_role";


--

-- Name: TABLE "vault_share_invites"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_share_invites" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_invites" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_invites" TO "service_role";


--

-- Name: TABLE "vault_share_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_share_logs" TO "anon";
GRANT ALL ON TABLE "public"."vault_share_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_share_logs" TO "service_role";


--

-- Name: TABLE "vault_shares"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."vault_shares" TO "anon";
GRANT ALL ON TABLE "public"."vault_shares" TO "authenticated";
GRANT ALL ON TABLE "public"."vault_shares" TO "service_role";


--

-- Name: TABLE "recovery_seeds"; Type: ACL; Schema: security_private; Owner: postgres
--

GRANT ALL ON TABLE "security_private"."recovery_seeds" TO "service_role";


--

-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";


--

-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";


--

-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";


--

-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";


--

-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";


--

-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";


--
-- PostgreSQL database dump complete
--

-- \unrestrict AEolIVcqqpppMFKF3Un5UJXFhLCcgZ6VKXNCCnsYhaYvoetLqGDaxVhHdQm8wCW
