BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "quotes" (
    "id" serial PRIMARY KEY,
    "quote" text NOT NULL,
    "author" text NOT NULL,
    "likes" json NOT NULL
);


--
-- MIGRATION VERSION FOR dart_quotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_quotes', '20240523125747811', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240523125747811', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240115074235544', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240115074235544', "timestamp" = now();


COMMIT;
