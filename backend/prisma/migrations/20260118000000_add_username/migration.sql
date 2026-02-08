-- AlterTable
ALTER TABLE "users" ADD COLUMN "username" VARCHAR(30);

-- CreateIndex (case-insensitive unique index)
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");
