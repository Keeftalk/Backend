-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_grace_uses Users manage grace uses for own habits; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage grace uses for own habits" ON "public"."habit_grace_uses" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_grace_uses"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_grace_uses"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid"))))));


--

-- Name: habit_grace_uses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."habit_grace_uses" ENABLE ROW LEVEL SECURITY;

--
