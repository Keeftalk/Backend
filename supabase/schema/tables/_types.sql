-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: group_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."group_role" AS ENUM (
    'owner',
    'admin',
    'member'
);


ALTER TYPE "public"."group_role" OWNER TO "postgres";

--

-- Name: notification_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."notification_type" AS ENUM (
    'story_like',
    'multi_device',
    'login_attempt',
    'security_alert',
    'app_broadcast',
    'system'
);


ALTER TYPE "public"."notification_type" OWNER TO "postgres";

--

-- Name: subscription_plan; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."subscription_plan" AS ENUM (
    'FREE',
    'PLUS_MONTHLY',
    'PLUS_YEARLY',
    'PRO_MONTHLY',
    'FAMILY_MONTHLY',
    'OFFICIAL'
);


ALTER TYPE "public"."subscription_plan" OWNER TO "postgres";

--

-- Name: user_plan; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."user_plan" AS ENUM (
    'free',
    'plus',
    'pro'
);


ALTER TYPE "public"."user_plan" OWNER TO "postgres";

--

-- Name: verification_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."verification_status" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE "public"."verification_status" OWNER TO "postgres";

--
