/*
  Warnings:

  - You are about to drop the column `avatar_url` on the `users` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "users" DROP COLUMN "avatar_url",
ADD COLUMN     "avatar_path" TEXT,
ADD COLUMN     "bio" VARCHAR(500),
ADD COLUMN     "birth_month" CHAR(7),
ALTER COLUMN "name" DROP NOT NULL;
