BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "quotes" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "quotes" (
    "id" bigserial PRIMARY KEY,
    "quote" text NOT NULL,
    "author" text NOT NULL,
    "likes" json NOT NULL
);

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_session_log" ADD COLUMN "userId" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_user_info" ALTER COLUMN "userName" DROP NOT NULL;

--
-- MIGRATION VERSION FOR dart_quotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_quotes', '20251212115045808', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251212115045808', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20250825102351908-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102351908-v3-0-0', "timestamp" = now();


COMMIT;
