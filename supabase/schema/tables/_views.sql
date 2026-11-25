-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: chat_list_metadata; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."chat_list_metadata" WITH ("security_invoker"='on') AS
 SELECT "c"."id" AS "chat_id",
    "c"."type",
    "c"."name" AS "group_name",
    "c"."avatar_url" AS "group_avatar",
    "cm"."user_id" AS "member_id",
    "p"."id" AS "partner_id",
    COALESCE("p"."full_name", "p"."username", "p"."phone", 'User'::"text") AS "partner_display_name",
    "p"."avatar_url" AS "partner_avatar",
    "p"."fcm_token" AS "partner_fcm_token"
   FROM ((("public"."chats" "c"
     JOIN "public"."chat_members" "cm" ON (("c"."id" = "cm"."chat_id")))
     LEFT JOIN "public"."chat_members" "cm2" ON ((("c"."id" = "cm2"."chat_id") AND ("cm2"."user_id" <> "cm"."user_id"))))
     LEFT JOIN "public"."profiles" "p" ON (("cm2"."user_id" = "p"."id")))
  WHERE (("c"."type" = 'ONE_TO_ONE'::"text") OR ("cm2"."user_id" IS NULL));


ALTER VIEW "public"."chat_list_metadata" OWNER TO "postgres";

--

-- Name: community_growth_daily; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."community_growth_daily" AS
 SELECT ("date_trunc"('day'::"text", "to_timestamp"((("join_date" / 1000))::double precision)))::"date" AS "day",
    "count"(*) AS "new_users"
   FROM "public"."profiles"
  WHERE ("join_date" > ((EXTRACT("epoch" FROM ("now"() - '30 days'::interval)) * (1000)::numeric))::bigint)
  GROUP BY (("date_trunc"('day'::"text", "to_timestamp"((("join_date" / 1000))::double precision)))::"date")
  ORDER BY (("date_trunc"('day'::"text", "to_timestamp"((("join_date" / 1000))::double precision)))::"date") DESC;


ALTER VIEW "public"."community_growth_daily" OWNER TO "postgres";

--

-- Name: connections; Type: VIEW; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW "public"."connections" WITH ("security_invoker"='true') AS
 SELECT "c"."owner_id" AS "user_a",
    "p"."id" AS "user_b"
   FROM ("public"."contacts" "c"
     JOIN "public"."profiles" "p" ON (("c"."phone" = "p"."phone")));


ALTER VIEW "public"."connections" OWNER TO "postgres";

--
