BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "albums" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "coverAssetId" uuid,
    "localRev" bigint NOT NULL DEFAULT 0,
    "serverRev" bigint,
    "serverSeq" bigint,
    "hlcWall" bigint NOT NULL,
    "hlcCounter" bigint NOT NULL,
    "deviceId" text NOT NULL,
    "deletedAt" timestamp without time zone,
    "pinned" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "albums_name_idx" ON "albums" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "assets" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "sha256" text NOT NULL,
    "localPath" text,
    "remoteUrl" text,
    "mimeType" text NOT NULL,
    "byteSize" bigint NOT NULL,
    "width" bigint,
    "height" bigint,
    "capturedAt" timestamp without time zone,
    "originalName" text,
    "syncState" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "assets_sha256_idx" ON "assets" USING btree ("sha256");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pins" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "slideId" uuid NOT NULL,
    "kind" text NOT NULL,
    "x" double precision NOT NULL,
    "y" double precision NOT NULL,
    "sizeScale" double precision NOT NULL DEFAULT 1.0,
    "color" text NOT NULL DEFAULT 'black'::text,
    "text" text,
    "targetSlideId" uuid,
    "zIndex" bigint NOT NULL DEFAULT 0,
    "hlcWall" bigint NOT NULL,
    "hlcCounter" bigint NOT NULL,
    "deviceId" text NOT NULL,
    "serverRev" bigint,
    "deletedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "_slidesPinsSlidesId" uuid
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "slides" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "albumId" uuid NOT NULL,
    "kind" text NOT NULL,
    "title" text NOT NULL DEFAULT ''::text,
    "commentText" text,
    "assetId" uuid,
    "orderKey" text NOT NULL,
    "zPinCounter" bigint NOT NULL DEFAULT 0,
    "dirty" bigint NOT NULL DEFAULT 0,
    "hlcWall" bigint NOT NULL,
    "hlcCounter" bigint NOT NULL,
    "deviceId" text NOT NULL,
    "serverRev" bigint,
    "deletedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "_albumsSlidesAlbumsId" uuid
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "pins"
    ADD CONSTRAINT "pins_fk_0"
    FOREIGN KEY("slideId")
    REFERENCES "slides"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "pins"
    ADD CONSTRAINT "pins_fk_1"
    FOREIGN KEY("_slidesPinsSlidesId")
    REFERENCES "slides"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "slides"
    ADD CONSTRAINT "slides_fk_0"
    FOREIGN KEY("albumId")
    REFERENCES "albums"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "slides"
    ADD CONSTRAINT "slides_fk_1"
    FOREIGN KEY("assetId")
    REFERENCES "assets"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "slides"
    ADD CONSTRAINT "slides_fk_2"
    FOREIGN KEY("_albumsSlidesAlbumsId")
    REFERENCES "albums"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR photopush
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('photopush', '20260930200346911', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260930200346911', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
