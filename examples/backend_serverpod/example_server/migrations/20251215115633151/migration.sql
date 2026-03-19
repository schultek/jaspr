BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_key" CASCADE;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_session_log" ADD COLUMN "userId" text;

--
-- MIGRATION VERSION FOR example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('example', '20251215115633151', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251215115633151', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


--
-- MIGRATION VERSION FOR 'mypod'
--
DELETE FROM "serverpod_migrations"WHERE "module" IN ('mypod');

COMMIT;
