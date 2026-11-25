-- Keeftalk production schema export
-- Source: production_schema_with_markers.sql
-- Generated automatically; preserve SQL definitions.

-- Name: habit_schedules Users manage schedules for own habits; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage schedules for own habits" ON "public"."habit_schedules" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_schedules"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."habits" "h"
  WHERE (("h"."id" = "habit_schedules"."habit_id") AND ("h"."owner_id" = ( SELECT "auth"."uid"() AS "uid"))))));


--

-- Name: habit_schedules; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."habit_schedules" ENABLE ROW LEVEL SECURITY;

--
