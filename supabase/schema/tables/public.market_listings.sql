-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: market_listings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."market_listings" (
    "id" "text" DEFAULT ("gen_random_uuid"())::"text" NOT NULL,
    "seller_id" "uuid" NOT NULL,
    "seller_name" "text" NOT NULL,
    "seller_avatar_url" "text",
    "seller_joined_year" "text" DEFAULT '2024'::"text",
    "seller_rating" numeric(3,2) DEFAULT 5.0,
    "seller_total_sales" integer DEFAULT 0,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "category_id" "text" NOT NULL,
    "category_name" "text" NOT NULL,
    "subcategory" "text",
    "price" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'TND'::"text" NOT NULL,
    "is_negotiable" boolean DEFAULT true NOT NULL,
    "condition" "text" DEFAULT 'USED'::"text" NOT NULL,
    "brand" "text",
    "model" "text",
    "location_area" "text" NOT NULL,
    "latitude" double precision,
    "longitude" double precision,
    "primary_image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '30 days'::interval) NOT NULL,
    "status" "text" DEFAULT 'ACTIVE'::"text" NOT NULL,
    "views_count" integer DEFAULT 0 NOT NULL,
    "saves_count" integer DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid",
    "cat" "text" DEFAULT 'other'::"text" NOT NULL,
    "sub" "text" DEFAULT 'Other'::"text" NOT NULL,
    "cd" "text" DEFAULT 'good'::"text" NOT NULL,
    "seller_alias" "text" DEFAULT ''::"text" NOT NULL,
    "as_identity" "text" DEFAULT 'alias'::"text" NOT NULL,
    "shape" "text" DEFAULT 'v'::"text" NOT NULL,
    "ts" bigint DEFAULT 0 NOT NULL,
    "exp" bigint DEFAULT 0 NOT NULL,
    "ext" integer DEFAULT 0 NOT NULL,
    "media" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "is_sold" boolean DEFAULT false NOT NULL,
    "pos_lat" double precision,
    "pos_lng" double precision
);


ALTER TABLE "public"."market_listings" OWNER TO "postgres";

--
